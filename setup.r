library(twitteR)
library(dplyr)
library(lubridate)
library(ggmap)

consumer_key <- "66Nl0EWZ7M9UeAc6hQp7590Ti"
consumer_secret <- "vR1aUhSO21GkjG4CWe4Iz7JmW2axt7aTFwKwpCALO4RVR8WLTH"
access_token <- "1411187382-PSMBLnNIgHE9F1LmvOSrhSXET9nvkofw6a73itU"
access_secret <- "eJqNCY4ISfJrNPvMM0LlO3ie7PIqKnJutxvkS37mffKl6"

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

eclipse <- searchTwitter("Eclipse2017 -filter:retweets", n = 300000, 
                         since = "2017-08-20", until = "2017-08-22",
                         retryOnRateLimit = 120)
eclipse.df <- twListToDF(eclipse)
eclipse.df <- mutate(eclipse.df, create_date = date(created))

eclipse_w_location <- filter(eclipse.df, !is.na(longitude)) %>%
  select(., id, longitude, latitude, created) %>%
  mutate(., longitude = as.double(longitude), latitude = as.double(latitude))

ggmap(get_map("United States", zoom = 4)) +
  geom_point(data = eclipse_w_location, aes(x = longitude, y = latitude, color = created))
