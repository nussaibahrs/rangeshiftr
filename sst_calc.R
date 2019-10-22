library(here)
library(raster)
library(ncdf4)

fname <- here("Data", "HadISST_sst.nc")
HadISST.b <- brick(fname)  
HadISST.b <- crop(HadISST.b, extent(130,  160, -30, -10))

yr <- seq(0, 1796, 12)

ann <- stack()

for (i in 1:length(yr)){
  cat("\r", i, " out of ", length(yr))
  ann <- stack(ann,calc(HadISST.b[[(i+1):yr[i+1]]], mean))
}

          
          