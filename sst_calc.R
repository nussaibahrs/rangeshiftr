library(here)
library(raster)

fname <- here("sst_data", "HadISST_sst.nc")
HadISST.b <- brick(fname)  

yr <- seq(0, 1796, 12)

ann <- stack()

for (i in 1:length(yr)){
  cat("\r", i, " out of ", length(yr))
  ann <- stack(ann,calc(HadISST.b[[(i+1):yr[i+1]]], mean))
}

          
          