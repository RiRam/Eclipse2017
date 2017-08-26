library(twitteR)
library(dplyr)
library(lubridate)
library(ggmap)
library(readr)

source(file = "credentials.r")

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

eclipse <- searchTwitter("Eclipse2017 -filter:retweets", n = 285718, 
                         since = "2017-08-20", until = "2017-08-23",
                         retryOnRateLimit = 120)
eclipse.df <- twListToDF(eclipse)
eclipse.df <- mutate(eclipse.df, create_date = date(created))

eclipse_w_location <- filter(eclipse.df, !is.na(longitude)) %>%
  select(., id, longitude, latitude, created) %>%
  mutate(., longitude = as.double(longitude), latitude = as.double(latitude))

ggmap(get_map("United States", zoom = 3)) +
  geom_point(data = eclipse_w_location, 
             aes(x = longitude, y = latitude, color = created))

write_csv(eclipse_w_location, path = "eclipsedata.csv")
