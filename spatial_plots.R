setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
library(rgdal)
library(scales)
library(RColorBrewer)

data = read.csv("data/rest_madrid_geocoded.csv")
data$reviews_spa_sh = data$reviews_spa / data$reviews_all

# Projections
longlat_p4s = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Load barrios map
mad = readOGR("data/GIS/barrios_madrid.shp", layer = "barrios_madrid")
proj4string(mad) = CRS("+init=epsg:25830")
mad = spTransform(mad, longlat_p4s)

# hot5 = readOGR("data/GIS/turismo_data/hoteles5.shp", layer = "hoteles5")
# hot5 = spTransform(hot5, longlat_p4s)

cols = brewer.pal(5,"RdBu")
data$spa_col = cols[5]
data$spa_col[data$reviews_spa_sh >= 0.2] = cols[4]
data$spa_col[data$reviews_spa_sh >= 0.4] = cols[3]
data$spa_col[data$reviews_spa_sh >= 0.6] = cols[2]
data$spa_col[data$reviews_spa_sh >= 0.8] = cols[1]

# Plot restaurants
pdf("plots/madrid_rest.pdf")
plot(mad)
points(x = data$long[!is.na(data$barrio_id)], y = data$lat[!is.na(data$barrio_id)],
  col = alpha(cols[1], 0.25), pch = ".", cex = 0.75)
dev.off()

pdf("plots/madrid_rest2.pdf")
plot(mad)
points(x = data$long, y = data$lat, col = alpha(data$spa_col, 0.5), pch = ".")
dev.off()

pdf("plots/madrid_rest2_only_above_50r.pdf")
plot(mad)
points(x = data$long[data$reviews_all > 50], y = data$lat[data$reviews_all > 50],
  col = alpha(data$spa_col, 0.5), pch = ".")
dev.off()
