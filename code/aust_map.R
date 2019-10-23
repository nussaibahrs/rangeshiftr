library(rworldmap)
library(raster)
library(cleangeo)
library(rgdal)
library(here)

world <- getMap()
world= clgeo_Clean(world)
new_proj <- "+proj=utm +zone=55 +south +units=m +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

b <- as(extent(100, 180, -50, 0), 'SpatialPolygons')
crs(b) <- crs(world)

aust <- crop(world, b)

aust <- spTransform(aust, CRS("+proj=utm +zone=55 +south +units=m +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

writeOGR(aust, here("data"), "australia", driver="ESRI Shapefile")

readOGR(here("data"), "australia")
