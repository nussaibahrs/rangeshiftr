library(RangeshiftR)
library(here)

# set up in- and output
# relative path from working directory:
dirpath = paste0(here("demo"), "/")

dir.create(here("demo", "Inputs"), showWarnings = TRUE)
dir.create(here("demo","Outputs"), showWarnings = TRUE)
dir.create(here("demo", "Output_Maps"), showWarnings = TRUE)

#carrying capacity
k=0.25 # half k as we increased resolution

# set up the landscape settings
land <- ImportedLandscape(LandscapeFile = "static_habitat2.txt",
                          Resolution = 4000,
                          Nhabitats = 2,
                          K = c(0,k),
                          SpDistFile = "initial_dist.txt",
                          SpDistResolution = 8000)

# transition matrix
trans_mat <- matrix(c(0, 1, 5, 0.6), # I decreased survivalrate of adults
                    # 0 means no adult can go back to the first stage (larvae)
                    # 1 means all 5 initial larvae survive and develop into adults
                    # 0.6 means survival rate of adult stages 
                    nrow = 2, byrow = F)

demo <- Demography(ReproductionType = 1,                   # simple sexual model
                   StageStruct = StageStructure(Stages=2,  # 1 juvenile + 2 adult stages
                                                TransMatrix=trans_mat, 
                                                MaxAge=10000, 
                                                SurvSched=2, 
                                                FecDensDep=T))
disp <-  Dispersal(Emigration = Emigration(DensDep=T, StageDep=T, 
                                           EmigProb = cbind(0:1,c(0.3,0),c(10.0,0),c(1.0,0)) ), 
                                              # I guess the second row first column is the 
                                              # immigration probability and set it to 0.3 from 0.5
                   Transfer = DispersalKernel(Distances = 4000),  # same as resolution
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
bbox(aust)

plot(bbox(aust), )
plot(aust, xlim=c(0, 1e06))
plot(suit)

x11(w=5.9, h=4.8)
plot(0,0, xlim=c(-1e6, 14e5), ylim=c(6.8e6, 8.7e6), 
     xlab="Longitude", ylab="Latitude")
plot(suit, add=TRUE, 
     legend=FALSE, col=c("grey90", "darkgreen"))
plot(aust, add=TRUE, col="white", border=NA)
legend("topright", fill=c("grey90", "darkgreen"), legend=c("Unsuitable","Suitable"),
       bg="white")

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
  geom_point(data=temp, aes(x=x, y=y, col=Year), inherit.aes = FALSE)+
  scale_colour_gradient(low = "coral", high = "#56B4E9") +
  coord_equal()

p

install.packages("gifski")
library(gganimate)

anim.gif <- p + transition_time(Year) +
  labs(title = "Year: {frame_time}")

# improve the gif
anim1 <- animate(anim.gif, fps = 10, duration = 30, rewind = F)

anim_save("anim1.gif", anim1)
