library(here)
library(tidyverse)
library(raster)
sadasd
# worldmap
coast <- rworldmap::getMap()

paleo.df <- read.csv("corals_Aug2019.csv") %>%
  filter(stg == 94 & early_interval == "Late Pleistocene" &
           between(paleolng, 130, 160) & between(paleolat, -30, -10))


x11()
plot(coast, xlim=c(130, 160), ylim=c(-30, -10))
points(dat$paleolng, dat$paleolat)

library(robis)
coral.occ <- occurrence("Acropora")
unique(coral.occ$basisOfRecord)


write.csv(hyac ,file = "hyac.csv", row.names = F)
