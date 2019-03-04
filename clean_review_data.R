# scp fvillami@icr-s02.ethz.ch:/home/fvillami/tripadvisor/files/madrid/reviews_data_madrid_backup.csv Documents/Academic/courses/SocDataScience_feb19/project
setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
library(stringr)
library(dplyr)
options(stringsAsFactors = FALSE)

list.files("data")[grepl("reviews_data_madrid_\\d", list.files("data"))]

reviews = rbind(
  read.csv("data/reviews_data_madrid_1_to_291.csv"),
  read.csv("data/reviews_data_madrid_292_to_1547.csv"),
  read.csv("data/reviews_data_madrid_1548_to_3177.csv"),
  read.csv("data/reviews_data_madrid_3178_to_7805.csv"))

### ----------------------------------------
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
reviews$translation = grepl("(Mejorar traducción)|(Puntuar traducción)|(Google Translation)",
  reviews$review)
reviews = subset(reviews, !translation)
# NOTE! IT PROBABLY MAKES SENSE TO CHECK THIS WITH THE RESTAURANT DATA AND SEE IF NO. OF
# REVIEWS MATCH. OTHERWISE PERHAPS TRY TO EXTRACT USERNAME AND LOOK FOR DUPLICATES?

### ----------------------------------------
### DATES

## Get time of review
ptt_rev = "(Reviewed\\s((\\w+\\s\\d+,\\s\\d+)|(\\d\\s\\w+\\sago)|(yesterday|today)))|(Opinión escrita\\s((el\\s\\d+\\sde\\s\\w+\\sde\\s\\d+)|(hace\\s(\\d|una|un)\\s\\w+)|(ayer|hoy)))"
reviews$review_date = str_sub(reviews$review, str_locate(reviews$review, ptt_rev))
reviews$review_date = gsub("(Reviewed|Opinión escrita(| el| hace)) ", "", reviews$review_date)
# Original pattern at regex101.com
# (Reviewed\s((\w+\s\d+,\s\d+)|(\d\s\w+\sago)|(yesterday)))|(Opinión escrita\s((el\s\d+\sde\s\w+\sde\s\d+)|(hace\s(\d|una|un)\s\w+)|(ayer)))

## Adapt to proper date format
# Set up "today" date
today = as.Date("2019-03-01")
# Counting 1 in letters
reviews$review_date = gsub("una semana", "1 semana", reviews$review_date)
reviews$review_date = gsub("un día", "1 día", reviews$review_date)
# Today/yesterday
reviews$review_date[reviews$review_date %in% c("today", "hoy")] = "0 days ago"
reviews$review_date[reviews$review_date %in% c("yesterday", "ayer")] = "1 days ago"
# Transform into dates those relative
i_days = grepl("días|days", reviews$review_date)
reviews$review_date[i_days] = str_sub(reviews$review_date[i_days], 1, 1)
reviews$review_date[i_days] = as.character(
  format(today - as.integer(reviews$review_date[i_days]), "%B %d, %Y"))
i_weeks = grepl("semana|week", reviews$review_date)
reviews$review_date[i_weeks] = str_sub(reviews$review_date[i_weeks], 1, 1)
reviews$review_date[i_weeks] = as.character(
  format(today - (as.integer(reviews$review_date[i_weeks])*7), "%B %d, %Y"))
# Transform SPA to ENG
reviews$review_date = gsub("(\\d+) de (\\w+) de", "\\2 \\1,", reviews$review_date)
reviews$review_date = gsub("enero", "January", reviews$review_date)
reviews$review_date = gsub("febrero", "February", reviews$review_date)
reviews$review_date = gsub("marzo", "March", reviews$review_date)
reviews$review_date = gsub("abril", "April", reviews$review_date)
reviews$review_date = gsub("mayo", "May", reviews$review_date)
reviews$review_date = gsub("junio", "June", reviews$review_date)
reviews$review_date = gsub("julio", "July", reviews$review_date)
reviews$review_date = gsub("agosto", "August", reviews$review_date)
reviews$review_date = gsub("septiembre", "September", reviews$review_date)
reviews$review_date = gsub("octubre", "October", reviews$review_date)
reviews$review_date = gsub("noviembre", "November", reviews$review_date)
reviews$review_date = gsub("diciembre", "December", reviews$review_date)
# Date transform
reviews$review_date = as.Date(reviews$review_date, "%B %d, %Y")
if(any(is.na(reviews$review_date))){warning("Date conversion failed! (review date)")}

## Get time of visit (if available)
ptt_visit = "((Fecha de la visita:\\s\\w+\\sde)|(Date of visit:\\s\\w+))\\s\\d\\d\\d\\d"
reviews$visit_date = str_sub(reviews$review, str_locate(reviews$review, ptt_visit))
reviews$visit_date = gsub("^(Date of visit|Fecha de la visita): ", "", reviews$visit_date)
# ((Fecha de la visita:\s\w+\sde)|(Date of visit:\s\w+))\s\d\d\d\d

## Adapt to proper date format
reviews$visit_date = gsub("(January|enero de) ", "01/01/", reviews$visit_date)
reviews$visit_date = gsub("(February|febrero de) ", "01/02/", reviews$visit_date)
reviews$visit_date = gsub("(March|marzo de) ", "01/03/", reviews$visit_date)
reviews$visit_date = gsub("(April|abril de) ", "01/04/", reviews$visit_date)
reviews$visit_date = gsub("(May|mayo de) ", "01/05/", reviews$visit_date)
reviews$visit_date = gsub("(June|junio de) ", "01/06/", reviews$visit_date)
reviews$visit_date = gsub("(July|julio de) ", "01/07/", reviews$visit_date)
reviews$visit_date = gsub("(August|agosto de) ", "01/08/", reviews$visit_date)
reviews$visit_date = gsub("(September|septiembre de) ", "01/09/", reviews$visit_date)
reviews$visit_date = gsub("(October|octubre de) ", "01/10/", reviews$visit_date)
reviews$visit_date = gsub("(November|noviembre de) ", "01/11/", reviews$visit_date)
reviews$visit_date = gsub("(December|diciembre de) ", "01/12/", reviews$visit_date)
reviews$visit_date = as.Date(reviews$visit_date, "%d/%m/%Y")

### ----------------------------------------

# Saving up (provisional)
write.csv(reviews, "reviews_madrid_tmp.csv", row.names = FALSE)
