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
                          K = c(0,k),
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

###### plot results ######
range_df <- readRange(s, dirpath)
par(mfrow=c(1,2))
plotAbundance(range_df)
plotOccupancy(range_df)

### plot results
par(mfrow=c(1,2))
plotAbundance(range_df, rep=F, sd=T)
plotOccupancy(range_df, rep=F, sd=T)

#map mean abundance ######
pop_df_long <- readPop(s, dirpath)

suit <- raster(here("demo", "Inputs", "static_habitat2.txt"))
aust <- rgdal::readOGR(here("data"), "australia")
plot(suit)

xmin <- extent(suit)[1]
ymin <- extent(suit)[3]



temp <- pop_df_long %>% group_by(x,y, Year) %>%
      summarise(m = mean(NInd)) %>%
  ungroup() %>%
  mutate(x = xmin + x,
         y = ymin+y)
####

wards.count <- nrow(aust@data)
# assign id for each lsoa

aust@data$id <- 1:wards.count
wards.fort <- fortify(aust, region='id')

p <-ggplot(wards.fort, aes(long, lat, group=group)) + 
  geom_polygon(colour='transparent', fill='lightgrey')+
  theme_minimal()+
  geom_point(data=temp, aes(x=x, y=y, col=Year), inherit.aes = FALSE)

install.packages("gifski")
library(gganimate)

p + transition_time(Year) +
  labs(title = "Year: {frame_time}")

anim_save("anim.gif")