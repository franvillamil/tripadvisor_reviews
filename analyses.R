setwd("~/Documents/Academic/courses/SocDataScience_feb19/project")
options(stringsAsFactors = FALSE)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stargazer)

data = read.csv("data/dataset_barrios.csv")

### Long form dataset - static analysis ---------------------------------------

data_long = data
names(data_long) = gsub("_(\\d\\d\\d\\d)", "__\\1", names(data_long))

data_long = data_long %>%
  gather(column, value, no_rests__2018:airbnb__2018) %>%
  separate(column, into = c("column", "year"), sep = "__") %>%
  spread(column, value)

data_long$airbnb_l = log(data_long$airbnb + 1)
data_long$rev_all = data_long$rev_eng + data_long$rev_spa

m1 = lm(rev_spa_sh ~ airbnb_l +
  log(hoteles4_5 + 1) + log(hotel_hostel + 1) + log(dist_sol) +
  log(rev_all + 1) + log(no_rests + 1) +
  factor(year) + factor(distrito), data = data_long)
m2 = lm(rev_spa_sh ~ airbnb_l * factor(year) +
  log(hoteles4_5 + 1) + log(hotel_hostel + 1) + log(dist_sol) +
  log(rev_all + 1) + log(no_rests + 1) +
  factor(distrito), data = data_long)

nd = data.frame(airbnb_l = seq(0, 8, 1))
nd$hoteles4_5 = mean(data_long$hoteles4_5, na.rm = T)
nd$hotel_hostel = mean(data_long$hotel_hostel, na.rm = T)
nd$dist_sol = mean(data_long$dist_sol, na.rm = T)
nd$no_rests = mean(data_long$no_rests, na.rm = T)
nd$rev_all = mean(data_long$rev_all, na.rm = T)
nd$year = 2017
nd$distrito = 1

nd$y = predict(m1, newdata = nd, response = "predict")
nd$se = predict(m1, newdata = nd, response = "predict", se.fit = TRUE)$se.fit
nd$upr = nd$y + nd$se * 1.96
nd$lwr = nd$y - nd$se * 1.96

pdf("plots/model_static.pdf", height = 4, width = 4)
ggplot(nd, aes(x = airbnb_l, y = y)) +
  geom_line() +
  geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.2) +
  scale_y_continuous(limits = c(0.7, 1), breaks = seq(0, 1, 0.1)) +
  labs(x = "\nLog. AirBnB listings", y = "Share of reviews in Spanish\n") +
  theme_classic()
dev.off()

nd2 = as.data.frame(expand.grid(airbnb_l = seq(0, 8, 1), year = c(2015, 2017, 2018)))
nd2$hoteles4_5 = mean(data_long$hoteles4_5, na.rm = T)
nd2$hotel_hostel = mean(data_long$hotel_hostel, na.rm = T)
nd2$dist_sol = mean(data_long$dist_sol, na.rm = T)
nd2$no_rests = mean(data_long$no_rests, na.rm = T)
nd2$rev_all = mean(data_long$rev_all, na.rm = T)
nd2$distrito = 1

nd2$y = predict(m2, newdata = nd2, response = "predict")
nd2$se = predict(m2, newdata = nd2, response = "predict", se.fit = TRUE)$se.fit
nd2$upr = nd2$y + nd2$se * 1.96
nd2$lwr = nd2$y - nd2$se * 1.96

pdf("plots/model2_static.pdf", height = 3, width = 8)
ggplot(nd2, aes(x = airbnb_l, y = y)) +
  geom_line() +
  geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.2) +
  scale_y_continuous(limits = c(0.7, 1), breaks = seq(0, 1, 0.1)) +
  facet_wrap(~year, ncol = 3) +
  theme_classic() +
  labs(x = "\nLog. AirBnB listings", y = "Share of reviews in Spanish\n") +
  theme(strip.background = element_blank(),
    strip.text = element_text(size = 12))
dev.off()

stargazer(m1, m2, type = "latex",
  omit = "distrito", omit.stat = c("f", "ser"),
  intercept.bottom = FALSE,
  covariate.labels = c("(Intercept)",
    "Log. AirBnB listings", "Log. Hotels 4/5*",
    "Log. Hostels + Hotels 1/2/3*", "Log. Distance to Sol (m)",
    "Log. total number of reviews", "Log. total number of bars/restaurants",
    "2017", "2018", "AirBnB x 2017", "AirBnB x 2018"),
  dep.var.labels = c(""), dep.var.labels.include = FALSE,
  star.char = c("+", "*", "**", "***"),
  star.cutoffs = c(0.1, 0.05, 0.01, 0.001),
  notes = "{\\bf Note:} $+ p<0.1; * p<0.05; ** p<0.01; *** p<0.001$.
    Province FE not shown.",
  notes.append = FALSE,
  no.space = TRUE)

### Dynamic - changes 2015-2017, 2017-2018, 2015-2018 -------------------------

head(data)

# Change variables
data$no_rests_ch_15_17 = data$no_rests_2017 / data$no_rests_2015
data$no_rests_ch_15_17[data$no_rests_ch_15_17 %in% c("Inf", NaN)] = NA
data$rev_spa_ch_15_17 = data$rev_spa_2017 / data$rev_spa_2015
data$rev_eng_ch_15_17 = data$rev_eng_2017 / data$rev_eng_2015
data$rev_spa_sh_ch_15_17 = data$rev_spa_sh_2017 / data$rev_spa_sh_2015
data$airbnb_ch_15_17 = data$airbnb_2017 / data$airbnb_2015
data$rev_ch_15_17 = (data$rev_eng_2017 + data$rev_spa_2017) /
  (data$rev_eng_2015 + data$rev_spa_2015)
# 2017-2018
data$no_rests_ch_17_18 = data$no_rests_2018 / data$no_rests_2017
data$no_rests_ch_17_18[data$no_rests_ch_17_18 %in% c("Inf", NaN)] = NA
data$rev_spa_ch_17_18 = data$rev_spa_2018 / data$rev_spa_2017
data$rev_eng_ch_17_18 = data$rev_eng_2018 / data$rev_eng_2017
data$rev_spa_sh_ch_17_18 = data$rev_spa_sh_2018 / data$rev_spa_sh_2017
data$airbnb_ch_17_18 = data$airbnb_2018 / data$airbnb_2017
data$rev_ch_17_18 = (data$rev_eng_2017 + data$rev_spa_2017) /
  (data$rev_eng_2018 + data$rev_spa_2018)
# 2015-2018
data$no_rests_ch_15_18 = data$no_rests_2018 / data$no_rests_2015
data$no_rests_ch_15_18[data$no_rests_ch_15_18 %in% c("Inf", NaN)] = NA
data$rev_spa_ch_15_18 = data$rev_spa_2018 / data$rev_spa_2015
data$rev_eng_ch_15_18 = data$rev_eng_2018 / data$rev_eng_2015
data$rev_spa_sh_ch_15_18 = data$rev_spa_sh_2018 / data$rev_spa_sh_2015
data$airbnb_ch_15_18 = data$airbnb_2018 / data$airbnb_2015
data$rev_ch_15_18 = (data$rev_eng_2018 + data$rev_spa_2018) /
  (data$rev_eng_2015 + data$rev_spa_2015)


m3 = lm(rev_spa_sh_ch_15_17 ~ airbnb_ch_15_17 + rev_ch_15_17 +
  no_rests_ch_15_17 + log(hoteles4_5 + 1) + log(hotel_hostel + 1) + log(dist_sol) +
  factor(distrito), data = data)
m4 = lm(rev_spa_sh_ch_17_18 ~ airbnb_ch_17_18 + rev_ch_17_18 +
  no_rests_ch_17_18 + log(hoteles4_5 + 1) + log(hotel_hostel + 1) + log(dist_sol) +
  factor(distrito), data = data)
m5 = lm(rev_spa_sh_ch_15_18 ~ airbnb_ch_15_18 + rev_ch_15_18 +
  no_rests_ch_15_18 + log(hoteles4_5 + 1) + log(hotel_hostel + 1) + log(dist_sol) +
  factor(distrito), data = data)

nd3 = data.frame(airbnb_ch_17_18 = seq(0, 8, 1))
nd3$rev_ch_17_18 = mean(data$rev_ch_17_18, na.rm = TRUE)
nd3$no_rests_ch_17_18 = mean(data$no_rests_ch_17_18, na.rm = TRUE)
nd3$hoteles4_5 = mean(data$hoteles4_5, na.rm = TRUE)
nd3$hotel_hostel = mean(data$hotel_hostel, na.rm = TRUE)
nd3$dist_sol = mean(data$dist_sol, na.rm = TRUE)
nd3$distrito = 1

nd3$y = predict(m4, newdata = nd3, response = "predict")
nd3$se = predict(m4, newdata = nd3, response = "predict", se.fit = TRUE)$se.fit
nd3$upr = nd3$y + nd3$se * 1.96
nd3$lwr = nd3$y - nd3$se * 1.96

pdf("plots/model_dynamic1718.pdf", height = 4, width = 4)
ggplot(nd3, aes(x = airbnb_ch_17_18, y = y)) +
  geom_line() +
  geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.2) +
  # scale_y_continuous(limits = c(0.7, 1), breaks = seq(0, 1, 0.1)) +
  labs(x = "\nChange AirBnB listings", y = "Change in share of reviews in Spanish\n") +
  theme_classic()
dev.off()

stargazer(m3, m4, m5, type = "latex",
  omit = "distrito", omit.stat = c("f", "ser"),
  intercept.bottom = FALSE,
  covariate.labels = c("(Intercept)",
    rep(c("Chg. AirBnB listings", "Chg. all reviews", "Chg. bars/rests"), 3),
    "Log. Hotels 4/5*", "Log. Host/Hotels 1/2/3*", "Log. Distance to Sol (m)"),
  dep.var.labels = c(""), dep.var.labels.include = FALSE,
  star.char = c("+", "*", "**", "***"),
  star.cutoffs = c(0.1, 0.05, 0.01, 0.001),
  notes = "{\\bf Note:} $+ p<0.1; * p<0.05; ** p<0.01; *** p<0.001$.
    Province FE not shown.",
  notes.append = FALSE,
  no.space = TRUE)
