setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
library(ggmap)

data = read.csv("data/rest_data_madrid.csv")

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
google_api_key = "..."
register_google(key = google_api_key)

for(i in 1:nrow(adr)){
  print(paste0(i, "/", nrow(adr), " ------ ", round(i/nrow(adr)*100, 0), "%"))
  coords = geocode(adr$address_mod[i])
  adr$long[i] = coords$lon
  adr$lat[i] = coords$lat
}

# Saving up
data = merge(unique(data), unique(adr[, c("name", "rank", "address", "long", "lat")]))
data = data[order(data$rank, data$name),]
write.csv(data, "data/rest_madrid_geocoded.csv", row.names = FALSE)
