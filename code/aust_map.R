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

#########
library(here)
library(raster)
library(rgdal)

aust <- readOGR(here("data"), "australia")
extent(aust)

temperature <- raster(here("data", "static_ann.tif"))
temperature <- projectRaster(temperature, crs=crs(aust), resolution = 8000)
plot(temperature)

bath <- raster(here("data", "bathy_5m.tif"))
bath <- crop(bath, extent(100, 180, -50, 0))
bath <- projectRaster(bath, crs=crs(aust))

brks <- c(-1, -25, -50, -100, -500)
bath_c <- rasterToContour(bath, levels=brks)
bath_c

x11(w=5.9, h=4.7);plot(temperature, xlim=c(-1e6, 1e6), ylim=c(7e6, 85e5))
plot(bath_c, add=TRUE)
plot(aust, add=TRUE, col="white")
