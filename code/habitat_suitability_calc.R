library(here)
library(raster)
library(ncdf4)

fname <- here("big files", "HadISST_sst.nc")
HadISST.b <- brick(fname)  
HadISST.b <- crop(HadISST.b, extent(130,  160, -30, -10))

##### static file ####
static_ann <- calc(HadISST.b, mean, na.rm=TRUE)
writeRaster(static_ann, here("data", "static_ann.tif"), format="GTiff",
            overwrite=TRUE)

yr <- seq(0, 1796, 12)

ann <- stack()

for (i in 1:length(yr)){
  cat("\r", i, " out of ", length(yr))
  ann <- stack(ann,calc(HadISST.b[[(i+1):yr[i+1]]], mean))
}

writeRaster(ann, here("data", "SST_ann.tif"), format = "GTiff", overwrite=TRUE)

##### 
ann <- stack(here("data", "SST_ann.tif"))
names(ann) <- 1870:2018

x11();plot(ann)

for (i in 1:149){
  temp <- ann[[i]]
  temp[temp >24 & temp < 28] <- 1
  temp[temp !=1] <- 0
  
  ann[[i]] <- temp
}

x11();plot(ann)

#### static SST
static_ann <- raster(here("data", "static_ann.tif"))
static_ann[static_ann > 24 & static_ann < 28] <- 1
static_ann[static_ann !=1] <- 0

plot(static_ann)

writeRaster(static_ann, here("data", "static_habitat1.tif"), format="GTiff",
            overwrite=TRUE)



####### habitat
library(raster)
library(here)

bath <- raster(here("data", "bathy_5m.tif"))
bath <- crop(bath, extent(130,  160, -30, -10))

sst_hab <- raster(here("data", "static_habitat1.tif"))

sst_hab <- resample(sst_hab, bath)
plot(sst_hab)

sst_hab[abs(bath) < 25 & sst_hab > 0] <- 2 #bathymetry in negative values
plot(sst_hab)

sst_hab[sst_hab != 2] <- 0
plot(sst_hab)

sst_hab[sst_hab == 2] <- 1
plot(sst_hab)

writeRaster(sst_hab, here("data", "static_habitat2.tif"), format="GTiff", overwrite=TRUE)

new_proj <- "+proj=utm +zone=55 +south +units=m +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
sst_hab2 <- projectRaster(sst_hab, crs=new_proj, res=8000) #convert to meters
sst_hab2
# plot(sst_hab2)
writeRaster(sst_hab2,  here("data", "static_habitat2.txt"), format="ascii", overwrite=TRUE, 
            datatype="INT4S")
  
