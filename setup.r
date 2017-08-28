library(twitteR)
library(dplyr)
library(lubridate)
library(ggmap)
library(readr)

# twitteR setup - consumer_key, consumer_secret, access_token, access_secret
source(file = "credentials.r")
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

# search for tweets containing "Eclipse2017"
eclipse <- searchTwitter("Eclipse2017 -filter:retweets", n = 300000, 
                         since = "2017-08-20", until = "2017-08-22",
                         retryOnRateLimit = 120)

# from list to dataframe
eclipse.df <- twListToDF(eclipse)

# wrangling
eclipse_w_location <- filter(eclipse.df, !is.na(longitude)) %>%
  select(., id, longitude, latitude, created) %>%
  mutate(., longitude = as.double(longitude), latitude = as.double(latitude), 
         create_time = as.integer(created)) %>%
  filter(., created > ymd_hms("2017-08-21 16:00:00") & 
           created < ymd_hms("2017-08-21 21:00:00")) 
labels <- pretty(eclipse_w_location$created, 5)

# mapping
ggmap(get_map("United States", zoom = 3)) +
  geom_point(data = eclipse_w_location, 
             aes(x = longitude, y = latitude, color = create_time), size = 1) +
  scale_color_gradient(name = "Tweet Time (UTC)", low="orange", high="black", 
                       breaks = as.integer(labels), 
                       labels = format(labels, "%Y-%m-%d %H:%M"))

# writing to csv
write_csv(eclipse_w_location, path = "eclipsedata.csv")
