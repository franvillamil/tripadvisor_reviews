setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
library(stringr)
library(dplyr)
options(stringsAsFactors = FALSE)

reviews = read.csv("reviews_data_madrid_backup.csv")

### BASICS

# Within data frame, split reviews and clean them out
reviews$reviews = str_split(reviews$reviews, "\n\n\n")
reviews$reviews = lapply(reviews$reviews, function(x)
  x = x[grepl("(Opinión escrita)|(Reviewed )", x)])

# Unlist reviews
rtimes = sapply(reviews$reviews, function(x) length(x))
reviews = data.frame(
  url = rep(reviews$url, times = rtimes),
  language = rep(reviews$language, times = rtimes),
  page = rep(reviews$page, times = rtimes),
  review = unlist(reviews$reviews)
)

# Is it a translation?
reviews$translation = grepl("(Mejorar traducción)|(Puntuar traducción)", reviews$review)
# NOTE! IT PROBABLY MAKES SENSE TO CHECK THIS WITH THE RESTAURANT DATA AND SEE IF NO. OF
REVIEWS MATCH. OTHERWISE PERHAPS TRY TO EXTRACT USERNAME AND LOOK FOR DUPLICATES?

### DATES

# Get time of review
ptt_rev = "(Reviewed\\s((\\w+\\s\\d+,\\s\\d+)|(\\d\\s\\w+\\sago)|(yesterday)))|(Opinión escrita\\s((el\\s\\d+\\sde\\s\\w+\\sde\\s\\d+)|(hace\\s(\\d|una|un)\\s\\w+)|(ayer)))"
reviews$review_date = str_sub(reviews$review, str_locate(reviews$review, ptt_rev))
reviews$review_date = gsub("(Reviewed|Opinión escrita (el|hace)) ", "", reviews$review_date)
# Original pattern at regex101.com
# (Reviewed\s((\w+\s\d+,\s\d+)|(\d\s\w+\sago)|(yesterday)))|(Opinión escrita\s((el\s\d+\sde\s\w+\sde\s\d+)|(hace\s(\d|una|un)\s\w+)|(ayer)))

# Get time of visit (if available)
ptt_visit = "((Fecha de la visita:\\s\\w+\\sde)|(Date of visit:\\s\\w+))\\s\\d\\d\\d\\d"
reviews$visit_date = str_sub(reviews$review, str_locate(reviews$review, ptt_visit))
reviews$visit_date = gsub("^(Date of visit|Fecha de la visita): ", "", reviews$visit_date)
# ((Fecha de la visita:\s\w+\sde)|(Date of visit:\s\w+))\s\d\d\d\d



# Adapt to proper date
today = as.Date("2019-03-01")
