setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
options(stringsAsFactors = FALSE)
library(dplyr)
library(tidyr)
library(rgeos)
library(rgdal)
load("data/function_adapt.RData")

# LOADING SHAPEFILE
mad = readOGR("data/GIS/barrios_madrid.shp", layer = "barrios_madrid")
proj4string(mad) = CRS("+init=epsg:25830")
mad = spTransform(mad,
  CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
mad$GEOCODIGO = as.integer(gsub("^0", "", mad$GEOCODIGO))

# Create barrio - ID equivalence, plus distrito
barrios = data.frame(barrio_id = mad@data$GEOCODIGO, barrio = adapt(mad@data$DESBDT))
barrios$distrito = as.integer(gsub("(^\\d\\d)\\d .*", "\\1", barrios$barrio))
barrios$barrio = gsub("^\\d\\d\\d ", "", barrios$barrio)
barrios$barrio_id = gsub("^\\d\\d\\d ", "", barrios$barrio_id)

### CREATE DATASET AND ADD TRIPADVISOR DATA -----------------------------------

# LOADING REVIEWS DATA
reviews = read.csv("data/reviews_rest_madrid.csv")
reviews = reviews %>% select(url, language, review_date)
# Date class & removing anything before 2019
reviews$review_date = as.Date(reviews$review_date)
reviews = subset(reviews, review_date < as.Date("2019-01-01"))

# LOADING RESTAURANT DATA
rests = read.csv("data/rest_madrid_geocoded.csv")
# Two duplicated restaurants for unknown reasons (maybe because scraping?)
rests = subset(rests, !(name %in% c("La Nueva", "Bar Pepito") & rank %in% c(4591, 4593)))
# Add restaurant info to reviews
reviews_nrow = nrow(reviews)
reviews = merge(reviews, rests[rests$url %in% reviews$url,
  c("url", "rank", "barrio", "barrio_id")])
if(nrow(reviews) != reviews_nrow){stop("Something happened when merging")}

# WTF = subset(rests, !url %in% reviews$url & !is.na(reviews_all))

# Aggregating number of reviews in Spa/Spa+Eng on
data_barrio = reviews %>%
  group_by(barrio_id) %>%
  summarize(
  # December 31, 2018
  no_rests_2018 = length(unique(url[review_date < "2019-01-01"])),
  rev_spa_2018 = length(url[review_date < "2019-01-01" & language  == "spanish"]),
  rev_eng_2018 = length(url[review_date < "2019-01-01" & language  == "english"]),
  # June 30, 2017
  no_rests_2017 = length(unique(url[review_date < "2017-07-01"])),
  rev_spa_2017 = length(url[review_date < "2017-07-01" & language  == "spanish"]),
  rev_eng_2017 = length(url[review_date < "2017-07-01" & language  == "english"]),
  # November 30, 2015
  no_rests_2015 = length(unique(url[review_date < "2015-12-01"])),
  rev_spa_2015 = length(url[review_date < "2015-12-01" & language  == "spanish"]),
  rev_eng_2015 = length(url[review_date < "2015-12-01" & language  == "english"])
  ) %>% filter(!is.na(barrio_id)) %>% as.data.frame()

# Creating variables
data_barrio = data_barrio %>% mutate(
  rev_spa_sh_2018 = rev_spa_2018 / (rev_spa_2018 + rev_eng_2018),
  rev_spa_sh_2017 = rev_spa_2017 / (rev_spa_2017 + rev_eng_2017),
  rev_spa_sh_2015 = rev_spa_2015 / (rev_spa_2015 + rev_eng_2015)
  )

data_barrio$rev_spa_sh_2018[data_barrio$rev_spa_2018 + data_barrio$rev_eng_2018 == 0] = NA
data_barrio$rev_spa_sh_2017[data_barrio$rev_spa_2017 + data_barrio$rev_eng_2017 == 0] = NA
data_barrio$rev_spa_sh_2015[data_barrio$rev_spa_2015 + data_barrio$rev_eng_2015 == 0] = NA

### ADD AIRBNB DATA -----------------------------------------------------------

airbnb15 = read.csv("data/madrid_listings_2oct2015.csv")
airbnb17 = read.csv("data/madrid_listings_8apr2017.csv")
airbnb18 = read.csv("data/madrid_listings_7nov2018.csv")

airbnb_barrio = function(airbnb){
  coordinates(airbnb) = ~longitude+latitude
  proj4string(airbnb) = proj4string(mad)
  airbnb$barrio_id = as.integer(over(airbnb, mad)$GEOCODIGO)
  airbnb$barrio = barrios$barrio[match(airbnb$barrio_id, barrios$barrio_id)]
  return(airbnb@data)
}

airbnb15 = airbnb_barrio(airbnb15)
airbnb17 = airbnb_barrio(airbnb17)
airbnb18 = airbnb_barrio(airbnb18)

# Keep this in mind, maybe robustness test?
# airbnb15$neighbourhood = adapt(airbnb15$neighbourhood)
# airbnb17$neighbourhood = adapt(airbnb17$neighbourhood)
# airbnb18$neighbourhood = adapt(airbnb18$neighbourhood)

airbnb_2015 = airbnb15 %>%
  group_by(barrio_id) %>%
  summarize(airbnb_2015 = length(id)) %>%
  as.data.frame()
airbnb_2017 = airbnb17 %>%
  group_by(barrio_id) %>%
  summarize(airbnb_2017 = length(id)) %>%
  as.data.frame()
airbnb_2018 = airbnb18 %>%
  group_by(barrio_id) %>%
  summarize(airbnb_2018 = length(id)) %>%
  as.data.frame()

data_barrio = merge(data_barrio, airbnb_2015, all.x = TRUE)
data_barrio = merge(data_barrio, airbnb_2017, all.x = TRUE)
data_barrio = merge(data_barrio, airbnb_2018, all.x = TRUE)

### ADD HOTELS ETC ------------------------------------------------------------

overlay_f = function(shp_name){
  # Load shapefile
  filename = paste0("data/GIS/turismo_data/", shp_name, ".shp")
  shp = readOGR(filename, layer = shp_name)
  # Change to longlat
  shp = spTransform(shp,
    CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  # Spatial overlay
  overlay = over(shp, mad)
  overlay$tipo = shp_name
  names(overlay)[names(overlay) == "GEOCODIGO"] = "barrio_id"
  # Return
  overlay = overlay[!is.na(overlay$barrio_id), c("barrio_id", "tipo")]
  return(overlay)
}

turismo_mad = rbind(
  overlay_f("host1"),
  overlay_f("host2"),
  overlay_f("host3"),
  overlay_f("hoteles1"),
  overlay_f("hoteles2"),
  overlay_f("hoteles3"),
  overlay_f("hoteles4"),
  overlay_f("hoteles5")
)

turismo_mad = turismo_mad %>%
  group_by(barrio_id) %>%
  summarize(
    hoteles4_5 = length(barrio_id[tipo %in% c("hoteles4", "hoteles5")]),
    hotel_hostel = length(barrio_id[!tipo %in% c("hoteles4", "hoteles5")])
  ) %>% as.data.frame()

data_barrio = merge(data_barrio, turismo_mad, all.x = TRUE)
data_barrio$hoteles4_5[is.na(data_barrio$hoteles4_5)] = 0
data_barrio$hotel_hostel[is.na(data_barrio$hotel_hostel)] = 0

head(data_barrio)

### DISTANCE FROM SOL ---------------------------------------------------------

# Centroids of each barrio
barrio_centroids = gCentroid(mad, byid = TRUE)
barrio_centroids = spTransform(barrio_centroids,
  CRS("+proj=utm +zone=30 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

# Sol spoints object
sol = data.frame(long = -3.703511, lat = 40.416897)
coordinates(sol) = ~long+lat
proj4string(sol) = proj4string(mad)
sol = spTransform(sol,
  CRS("+proj=utm +zone=30 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

# Create and append
distances = as.numeric(gDistance(barrio_centroids, sol, byid = TRUE))
data_barrio$dist_sol = distances[match(data_barrio$barrio_id, mad$GEOCODIGO)]

### ---------------------------------------------------------------------------
### SAVING
data_barrio = merge(data_barrio, barrios)
write.csv(data_barrio, "data/dataset_barrios.csv", row.names = FALSE)
