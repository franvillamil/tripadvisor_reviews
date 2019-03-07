setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
options(stringsAsFactors = FALSE)
library(dplyr)
library(tidyr)

# LOADING REVIEWS DATA
reviews = read.csv("data/reviews_rest_madrid.csv")
reviews = reviews %>% select(url, language, review_date)
# Date class & removing anything before 2019
reviews$review_date = as.Date(reviews$review_date)
reviews = subset(reviews, review_date < as.Date("2019-01-01"))

# LOADING RESTAURANT DATA
rests = read.csv("data/rest_madrid_geocoded.csv")

table(rests$reviews_all > 50) # what about subsetting a bit?

if(!all(unique(reviews$url) %in% rests$url)){stop("Some reviews URLs not in restaurant data")}

WTF = subset(rests, !url %in% reviews$url & !is.na(reviews_all))
