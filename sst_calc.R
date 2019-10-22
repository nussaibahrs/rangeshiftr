library(here)
library(raster)
library(ncdf4)

fname <- here("big files", "HadISST_sst.nc")
HadISST.b <- brick(fname)  
HadISST.b <- crop(HadISST.b, extent(130,  160, -30, -10))


##### static file ####
static_ann <- calc(HadISST.b, mean, na.rm=TRUE)
writeRaster(static_ann, here("Data", "static_ann.tif"), format="GTiff",
            overwrite=TRUE)

yr <- seq(0, 1796, 12)

ann <- stack()

for (i in 1:length(yr)){
  cat("\r", i, " out of ", length(yr))
  ann <- stack(ann,calc(HadISST.b[[(i+1):yr[i+1]]], mean))
}

writeRaster(ann, here("Data", "SST_ann.tif"), format = "GTiff", overwrite=TRUE)

##### 
ann <- stack(here("Data", "SST_ann.tif"))
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
static_ann <- raster(here("Data", "static_ann.tif"))
static_ann[static_ann > 24 & static_ann < 28] <- 1
static_ann[static_ann !=1] <- 0

plot(static_ann)

writeRaster(static_ann, here("Data", "static_habitat1.tif"), format="GTiff",
            overwrite=TRUE)



####### habitat
bath <- raster(here("Data", "bathy_5m.tif"))
bath <- crop(bath, extent(130,  160, -30, -10))

sst_hab <- raster(here("Data", "static_habitat1.tif"))

sst_hab <- resample(sst_hab, bath)
plot(sst_hab)

sst_hab[bath < 25 & sst_hab > 0] <- 2
plot(sst_hab)

sst_hab[sst_hab != 2] <- 0
plot(sst_hab)

sst_hab[sst_hab == 2] <- 1
plot(sst_hab)

