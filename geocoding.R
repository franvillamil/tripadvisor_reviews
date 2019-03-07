setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
options(stringsAsFactors = FALSE)
library(ggmap)
library(rgdal)
library(sp)

data = read.csv("data/rest_data_madrid.csv")

### 1. GEOCODE ADDRESSES

# Setting up and cleaning address
adr = data[, c("name", "rank", "address")]
adr$address_mod = gsub(" \\|(.*?),", ",", adr$address)
adr$address_mod = gsub("#( |)(\\d+)", "\\2", adr$address_mod)
adr$address_mod[adr$address_mod ==
  "Calle Bravo Murillo 122 Mercado de Maravillas, 28020 Madrid, Spain"] =
  "Calle Bravo Murillo 122, 28020 Madrid, Spain"
adr$address_mod[adr$address_mod ==
  "Mercado Maravillas, 28020 Madrid, Spain"] =
  "Calle Bravo Murillo 122, 28020 Madrid, Spain"
adr$long = NA
adr$lat = NA

# Geocoding with Google API
google_api_key = "AIzaSyB64o2qbiFEE49vVTMEpi3QiZ_2oXYANfk"
register_google(key = google_api_key)

for(i in 1:nrow(adr)){
  print(paste0(i, "/", nrow(adr), " ------ ", round(i/nrow(adr)*100, 0), "%"))
  coords = geocode(adr$address_mod[i])
  adr$long[i] = coords$lon
  adr$lat[i] = coords$lat
}

# Merge with the rest of information
data = merge(unique(data), unique(adr[, c("name", "rank", "address", "long", "lat")]))

### 2. ASSIGN CORRESPONDING BARRIO IN MADRID

# Load barrios map
mad = readOGR("data/GIS/barrios_madrid.shp", layer = "barrios_madrid")
proj4string(mad) = CRS("+init=epsg:25830")
mad = spTransform(mad, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

# Set up coordinates
coordinates(data) = ~long+lat
proj4string(data) = proj4string(mad)

# Spatial overlay
barrios = over(data, mad)
data$barrio = as.character(barrios$DESBDT)
data$barrio_id = as.character(barrios$GEOCODIGO)

# Adapting
data$barrio = gsub("\xfc", "u", data$barrio)
data$barrio = gsub("\xed", "i", data$barrio)
data$barrio = gsub("\xf1", "n", data$barrio)
data$barrio = gsub("\xf3", "o", data$barrio)
data$barrio = gsub("\xc1", "A", data$barrio)
data$barrio = gsub("\xe1", "a", data$barrio)
data$barrio = gsub("\xe9", "e", data$barrio)
data$barrio = gsub("\xfa", "u", data$barrio)

# Save coordinates columns
long = coordinates(data)[,1]
lat = coordinates(data)[,2]

# Back to DF
data = data@data

# Add coordinates columns
data$long = long
data$lat = lat

# ------------------------------------
# Saving up
data = data[order(data$rank, data$name),]
write.csv(data, "data/rest_madrid_geocoded.csv", row.names = FALSE)
