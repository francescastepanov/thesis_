rm(list = ls())

library(ggpubr)
library(readr)
library(plyr)
library(mapdata)
library(maptools)
library(dplyr) 

d1 <- read_csv("/Users/Kisei/Dropbox/PAPER Kisei Bia JWS range shift/data/citizen science/Eric/EricMailander_Observations.csv")
d1 <- read_csv("/Users/ktanaka/Dropbox (MBA)/PAPER Kisei Bia JWS range shift/data/community science/Eric/EricMailander_Observations.csv")

d1$trips = 1

d1$juv_juv = ifelse(d1$min_stage == "juvenile" & d1$max_stage == "juvenile", d1$n_sharks, NA)
d1$juv_sub = ifelse(d1$min_stage == "juvenile" & d1$max_stage == "subadult", d1$n_sharks, NA)
d1$sub_sub = ifelse(d1$min_stage == "subadult" & d1$max_stage == "subadult", d1$n_sharks, NA)
d1$na_na = 0

d1 = d1 %>% group_by(year) %>% 
  summarise(trips = sum(trips, na.rm = T),
            juv_juv = sum(juv_juv, na.rm = T),
            juv_sub = sum(juv_sub, na.rm = T)*0.8,
            sub_sub = sum(sub_sub, na.rm = T),
            na_na = sum(na_na, na.rm = T)) %>% 
  mutate(sharks_per_trip = (na_na + juv_juv + juv_sub)/trips, 
         # cpue = scales::rescale(sharks_per_trip, to = c(0,1)),
         cpue = sharks_per_trip/max(sharks_per_trip),
         category = "boat & drone") %>% 
  select(year, cpue, category)

# d_2013 = data.frame(year = 2013, 
#                     cpue = 0, 
#                     category = "boat & drone")
# d1 = rbind(d1, d_2013)

d2 <- read_csv("/Users/Kisei/Dropbox/PAPER Kisei Bia JWS range shift/data/citizen science/iNat/iNat_observs-90879_21May2020.csv")
d2 <- read_csv("/Users/ktanaka/Dropbox (MBA)/PAPER Kisei Bia JWS range shift/data/community science/iNat/iNat_observs-90879_21May2020.csv")

# d2$year = substr(as.character(d2$observed_on), 1, 4)
# d2$sharks = 1

d2 = d2 %>% group_by(year) %>% 
  summarise(sharks = sum(eligible, na.rm = T)) %>% 
  mutate(cpue = sharks/max(sharks),
         # cpue = scales::rescale(sharks, to = c(0,1)),
         category = "iNat") %>%
  select(year, cpue, category)

d_2013 = data.frame(year = 2013, 
                    cpue = 0, 
                    category = "iNat")

d2 = rbind(d2, d_2013)

setwd("/Users/Kisei/Desktop")
png(paste0("Fig.1c_", Sys.Date(), ".png"), res = 300, height = 3, width = 5, units = "in")
# pdf(paste0("Fig.1c_", Sys.Date(), ".pdf"), height = 4, width = 5)
rbind(d1, d2) %>% 
  ggplot(aes(year, cpue, color = category, group = category)) +
  geom_point(size = 3, alpha = 0.8) + 
  geom_line(size = 2, alpha = 0.8, show.legend = F) +
  scale_color_viridis_d("") + 
  theme_pubr() + 
  ylab("Normalized Frequency") + 
  theme(legend.position = c(0.18, 0.95))
dev.off()

