library(RangeshiftR)
library(here)

# set up in- and output
# relative path from working directory:
dirpath = paste0(here("demo"), "/")

dir.create(here("demo", "Inputs"), showWarnings = TRUE)
dir.create(here("demo","Outputs"), showWarnings = TRUE)
dir.create(here("demo", "Output_Maps"), showWarnings = TRUE)

#carry capacity
k=0.15
# set up the landscape settings
land <- ImportedLandscape(LandscapeFile = "static_habitat2.txt",
                          Resolution = 8000,
                          Nhabitats = 2,
                          K = c(0,.k),
                          SpDistFile = "initial_dist.txt",
                          SpDistResolution = 8000)

# transition matrix
trans_mat <- matrix(c(0, 1, 5, 0.8), 
                    nrow = 2, byrow = F)

demo <- Demography(ReproductionType = 1,                   # simple sexual model
                   StageStruct = StageStructure(Stages=2,  # 1 juvenile + 2 adult stages
                                                TransMatrix=trans_mat, 
                                                MaxAge=10000, 
                                                SurvSched=2, 
                                                FecDensDep=T))
disp <-  Dispersal(Emigration = Emigration(DensDep=T, StageDep=T, 
                                           EmigProb = cbind(0:1,c(0.5,0),c(10.0,0),c(1.0,0)) ), 
                   Transfer = DispersalKernel(Distances = 8000), 
                   Settlement = Settlement(FindMate = F) )

# initialisation
init <- Initialise(InitType = 1, # = initialisation from a loaded species distribution map
                   PropStages = c(0,1),
                   SpType = 1,   # = all suitable cells within all distribution presence cells
                   NrCells = 2, # = Number of cells for initiation, 0 is random
                   InitDens = 1) # = at carrying capacity, 1 is at half

yr = 100
out_ = 5
sim_0 <- Simulation(Simulation = 0, 
                    Replicates = 5, 
                    Years = yr,
                    OutIntPop = out_,
                    OutIntOcc = out_,
                    OutIntRange = out_)


s <- RSsim(land = land, demog = demo, dispersal = disp, 
           simul = sim_0, init = init)

# run simulation
RunRS(s, dirpath)



### plot results
range_df <- readRange(s, dirpath)
par(mfrow=c(1,2))
plotAbundance(range_df)
plotOccupancy(range_df)



x11()
new_proj <- "+proj=utm +zone=55 +south +units=m +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
# worldmap

coast <- raster(here("demo", "Inputs", "static_habitat2.txt"))

x11()
plot(coast)
points(min_Y~min_X, data=range_df)
