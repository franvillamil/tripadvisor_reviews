setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
options(stringsAsFactors = FALSE)
library(ggplot2)
library(dplyr)
library(scales)
library(tidyr)

reviews = read.csv("reviews_madrid_tmp.csv");nrow(reviews)
reviews = reviews %>% select(url, language, review_date)

# Date class
reviews$review_date = as.Date(reviews$review_date)
reviews = subset(reviews, review_date < as.Date("2019-01-01"))

### BASIC PLOTS

pdf("plots/reviews_date.pdf", width = 7, height = 4)
ggplot(reviews, aes(x = review_date)) +
  geom_histogram(binwidth=90, colour="white") +
  scale_x_date(labels = date_format("%Y"),
    breaks = "1 year", limits = c(min(reviews$review_date), max(reviews$review_date))) +
  theme_classic() + labs(x = "", y = "Total monthly number of reviews\n")
dev.off()

pdf("plots/reviews_date_lang.pdf", width = 7, height = 7)
ggplot(reviews, aes(x = review_date))+#, group = factor(language), fill = factor(language))) +
  geom_histogram(binwidth=90, color = "white") +
  scale_x_date(labels = date_format("%Y"),
    breaks = "1 year", limits = c(min(reviews$review_date), max(reviews$review_date))) +
  theme_classic() + labs(x = "", y = "Total monthly number of reviews\n") +
  facet_wrap(~ language, ncol = 1)
dev.off()


pdf("plots/reviews_date_lang2.pdf", width = 7, height = 7)
ggplot(reviews, aes(x = review_date, group = factor(language), fill = factor(language))) +
  geom_histogram(binwidth=90, color = "white") +
  scale_x_date(labels = date_format("%Y"),
    breaks = "1 year", limits = c(min(reviews$review_date), max(reviews$review_date))) +
  theme_classic() +
  labs(x = "", y = "Total monthly number of reviews\n", fill = "Language of review") +
  theme(legend.position = c(0.15,0.9)) +
  scale_fill_manual(labels = c("English", "Spanish"), values = c("#0e80d8", "#ed4747"))
dev.off()

### DISTRIBUTION OF RESTAURANTS BY % ENGLISH OVER TIME

st18 = as.Date("2018-01-01")
st17 = as.Date("2017-01-01")
st16 = as.Date("2016-01-01")
st15 = as.Date("2015-01-01")
st14 = as.Date("2014-01-01")

share_spa = reviews %>%
  group_by(url) %>%
  summarize(
    bef19 = length(url[language == "spanish"]) / length(url),
    bef18 = length(url[language == "spanish" & review_date < st18]) / length(url),
    bef17 = length(url[language == "spanish" & review_date < st17]) / length(url),
    bef16 = length(url[language == "spanish" & review_date < st16]) / length(url),
    bef15 = length(url[language == "spanish" & review_date < st15]) / length(url),
    bef14 = length(url[language == "spanish" & review_date < st14]) / length(url),
    bef19_total = length(url),
    bef18_total = length(url[review_date < st18]),
    bef17_total = length(url[review_date < st17]),
    bef16_total = length(url[review_date < st16]),
    bef15_total = length(url[review_date < st15]),
    bef14_total = length(url[review_date < st14])
  ) %>% as.data.frame()
share_spa$bef18[share_spa$bef18_total == 0] = NA
share_spa$bef17[share_spa$bef17_total == 0] = NA
share_spa$bef16[share_spa$bef16_total == 0] = NA
share_spa$bef15[share_spa$bef15_total == 0] = NA
share_spa$bef14[share_spa$bef14_total == 0] = NA
share_spa = gather(share_spa, time, share_spa, bef19:bef14)
share_spa = subset(share_spa, !is.na(share_spa), select = c(url, time, share_spa))

share_spa$time = factor(share_spa$time)
levels(share_spa$time) = c("Before 2014", "Before 2015", "Before 2016",
  "Before 2017", "Before 2018", "Before 2019")

pdf("plots/share_spa_reviews_over_time.pdf")
ggplot(share_spa, aes(x = share_spa)) +
  geom_histogram(binwidth = 0.05, color = "white") +
  facet_wrap(~time, ncol = 3) +
  theme_bw() +
  theme(strip.background = element_blank(),
    strip.text = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(colour = "black")) +
  labs(y = "", x = "\nShare of reviews in Spanish (vs Spa + Eng) for each restaurant in Madrid")
dev.off()
