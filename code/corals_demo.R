library(here)
library(tidyverse)
library(raster)

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

names(coral.occ)

hyac <- coral.occ %>%
  filter(scientificName == "Acropora hyacinthus" &
           between(decimalLongitude, 130, 160) & between(decimalLatitude, -30, -10))


write.csv(hyac ,file = "hyac.csv", row.names = F)

# plot the occurrence data of Acropora Hyacinthus
x11()
plot(coast, xlim=c(130, 160), ylim=c(-30, -10), col= "grey70")
points(hyac$decimalLongitude, hyac$decimalLatitude, col = "black", 
       bg = "coral", pch= 21)

# plot the SST data
library(RColorBrewer)

static_ann <- raster(here("data", "static_ann.tif"))
plot(static_ann, col=rev(brewer.pal(n = 6, name = "Spectral")))

# plot the Water depth (Bathymetry)
bath <- raster(here("data", "bathy_5m.tif"))
bath <- crop(bath, extent(130,  160, -30, -10))

colfunc <- colorRampPalette(c("darkblue", "blue"))
plot(bath, col= colfunc(10))

