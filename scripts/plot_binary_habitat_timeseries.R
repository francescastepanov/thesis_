rm(list = ls())

library(dplyr)
library(ggpubr)
library(ggthemes)
library(raster)
library(scales)
library(zoo)

load("/Users/Kisei/jws_range/data/lat_area.RData")
load("/Users/Kisei/Dropbox/PAPER Kisei Bia JWS range shift/data/tags/t_IQR.Rdata")

df = merge(df, lat_area)
df = df %>% subset(depth > -1000)
df$month = substr(df$time, 6, 7)

########################################################
### lat-bin specific time series (daily or annually) ###
########################################################

df = df %>% subset(year %in% c(1982:2019))

t0 = df %>% 
  group_by(time) %>% 
  mutate(area = area * z) %>% 
  summarise(area = sum(area)) %>% 
  mutate(time = as.Date(time),
         type = "22.9° N - 47.4° N (Cali CC LME)")

t0_year = t0 %>% 
  mutate(year = substr(time, 1, 4)) %>% 
  group_by(year) %>% 
  summarise(area = mean(area)) %>% 
  mutate(year = as.numeric(year),
         type = "22.9° N - 47.4° N (Cali CC LME)")

t1 = df %>% 
  group_by(time) %>% 
  subset(y >= 22.9 & y <= 34.4) %>%
  mutate(area = area * z) %>% 
  summarise(area = sum(area)) %>% 
  mutate(time = as.Date(time),
         type = "22.9° N - 34.4° N (S.boundary Cali CC LME - Point Conception)")

t1_year = t1 %>% 
  mutate(year = substr(time, 1, 4)) %>% 
  group_by(year) %>% 
  summarise(area = mean(area)) %>% 
  mutate(year = as.numeric(year),
         type = "22.9° N - 34.4° N (S.boundary Cali CC LME - Point Conception)")

t2 = df %>% 
  group_by(time) %>% 
  subset(y >= 34.4 & y <= 37.8) %>%
  mutate(area = area * z) %>% 
  summarise(area = sum(area)) %>% 
  mutate(time = as.Date(time),
         type = "34.4° N - 37.8° N (Point Conception - San Francisco)")

t2_year = t2 %>% 
  mutate(year = substr(time, 1, 4)) %>% 
  group_by(year) %>% 
  summarise(area = mean(area)) %>% 
  mutate(year = as.numeric(year),
         type = "34.4° N - 37.8° N (Point Conception - San Francisco)")

t3 = df %>% 
  group_by(time) %>% 
  subset(y >= 37.8) %>%
  mutate(area = area * z) %>% 
  summarise(area = sum(area)) %>% 
  mutate(time = as.Date(time),
         type = "37.8° N - 47.4° N (San Francisco - N.boundary Cali CC LME)")

t3_year = t3 %>% 
  mutate(year = substr(time, 1, 4)) %>% 
  group_by(year) %>% 
  summarise(area = mean(area)) %>% 
  mutate(year = as.numeric(year),
         type = "37.8° N - 47.4° N (San Francisco - N.boundary Cali CC LME)")

t3_missing_days = data.frame(time = setdiff(as.character(t0$time), as.character(t3$time)),
                             area = NA, 
                             type = "37.8° N - 47.4° N (San Francisco - N.boundary Cali CC LME)")

t3_missing_days$time = as.Date(t3_missing_days$time)
t3 = rbind(t3, t3_missing_days)
t3 <- t3[order(t3$time),]

t = rbind(t1, t2, t3)

t$type <- factor(t$type, levels = c(
  "37.8° N - 47.4° N (San Francisco - N.boundary Cali CC LME)",
  "34.4° N - 37.8° N (Point Conception - San Francisco)",
  "22.9° N - 34.4° N (S.boundary Cali CC LME - Point Conception)"))

t_year = rbind(t1_year, t2_year, t3_year)

t_year$type <- factor(t_year$type, levels = c(
  "37.8° N - 47.4° N (San Francisco - N.boundary Cali CC LME)",
  "34.4° N - 37.8° N (Point Conception - San Francisco)",
  "22.9° N - 34.4° N (S.boundary Cali CC LME - Point Conception)"))

# p1 = ggplot(t, aes(x = time, y = area, color = area)) +
#   geom_line(aes(y = rollmean(area, 10, na.pad = TRUE)), alpha = 0.5) +
#   stat_smooth(method = "loess", span = 0.1) +
#   scale_colour_viridis_c("km^2") +
#   ylab("JWS Thermal Habitat (sq.km)") +
#   ggtitle("10-day running mean. Based on probablistic model") +
#   facet_wrap(.~type, scales = "free_y", nrow = 1) +
#   scale_y_continuous(labels = scientific) +
#   theme_pubr(I(20)) +
#   theme(legend.position = "none")

summary(lm(area ~ time, data = t0))
summary(lm(area ~ time, data = t1))
summary(lm(area ~ time, data = t2))
summary(lm(area ~ time, data = t3))

summary(lm(area ~ year, data = t0_year))
summary(lm(area ~ year, data = t1_year))
summary(lm(area ~ year, data = t2_year))
summary(lm(area ~ year, data = t3_year))

p1 = ggplot(t0, aes(x = time, y = area/10000, color = "type", fill = "type")) +
  stat_smooth(method = "loess", span = 0.1, aes(color = "type"), show.legend = T) +
  stat_smooth(method = "lm", linetype = "dashed", se = F) +
  ylab(bquote('Available Habitat ('*10^4~km^2*')')) +  xlab("") +
  facet_wrap(.~type) + 
  theme_few(I(12)) + 
  theme(legend.position = "none")

p1_year = ggplot(t0_year, aes(x = year, y = area/10000, color = "type", fill = "type")) +
  # geom_point(shape = 1) + 
  stat_smooth(method = "loess", span = 0.2, aes(color = "type")) +
  stat_smooth(method = "lm", linetype = "dashed", se = F) +
  ylab(bquote('Available Habitat ('*10^4~km^2*')')) +  xlab("") +
  facet_wrap(.~type) + 
  theme_few(I(12)) + 
  theme(legend.position = "none")

p2 = ggplot(t, aes(x = time, y = area/10000, color = type, fill = type)) +
  scale_fill_viridis_d("") +
  scale_colour_viridis_d("") +
  stat_smooth(method = "loess", span = 0.1, aes(color = type)) +
  stat_smooth(method = "lm", linetype = "dashed", se = F) +
  ylab("") + xlab("") + 
  facet_wrap(.~type, scales = "free_y", ncol = 1) + 
  theme_few(I(12)) + 
  theme(legend.position = "none")

p2_year = ggplot(t_year, aes(x = year, y = area/10000, color = type, fill = type)) +
  # geom_point(shape = 1) + 
  scale_fill_viridis_d("") +
  scale_colour_viridis_d("") +
  stat_smooth(method = "loess", span = 0.2, aes(color = type)) +
  stat_smooth(method = "lm", linetype = "dashed", se = F) +
  ylab("") + xlab("") + 
  facet_wrap(.~type, scales = "free_y", ncol = 1) + 
  theme_few(I(12)) +
  theme(legend.position = "none")

setwd("/Users/Kisei/Desktop")
setwd("/Users/ktanaka/Desktop")

pdf(paste0("Fig.4_", Sys.Date(), ".pdf"), height = 7, width = 10)
# cowplot::plot_grid(p1, p2, ncol = 2)
cowplot::plot_grid(p1_year, p2_year, ncol = 2)
dev.off()

