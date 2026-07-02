### Whitefish sample summary
library(tidyverse)
library(readxl)
library(ggmap)
library(ggrepel)
library(sf) #used to work with spatial features once they are in R
library(rgdal) #used to read spatial features into R
library(ggsci)
library(leaflet)
library(arcpullr)

LWF_genetic_masterlist <- read_excel("./data/LWF genetic masterlist.xlsx", 
                                     sheet = "SP_dataset")
#View(LWF_genetic_masterlist)


coords <- LWF_genetic_masterlist %>% group_by(WaterbodyName, Latitude, Longitude) %>% summarize(N= n() )

## quick leaflet map
icon.walleye <- makeAwesomeIcon(icon= 'flag', markerColor = 'blue', iconColor = 'black')

leaflet() %>% 
  addTiles() %>% 
  addAwesomeMarkers(data = LWF_genetic_masterlist,
                    group = "Whitefish", 
                    icon = icon.walleye, 
                    label = ~as.character(paste(WaterbodyName)))

### Static map figure

LWF_genetic_masterlist_p <- LWF_genetic_masterlist %>% group_by(WaterbodyName) %>% summarise(Latitude = first(Latitude), Longitude = first(Longitude), N= n())
LWF_genetic_masterlist_p <- LWF_genetic_masterlist_p %>% filter(WaterbodyName !="Little Chicken Island")

main_lakes_url <- "https://services7.arcgis.com/Tk0IbKIKhaoYn5sa/ArcGIS/rest/services/MainLakes/FeatureServer/0"
states_url <- "https://services7.arcgis.com/Tk0IbKIKhaoYn5sa/ArcGIS/rest/services/GreatLakesSystems_States/FeatureServer/0"
provs_url <- "https://gis.glc.org/server/rest/services/Political/Canadian_Province_Boundary/MapServer/0"

main_lakes <- get_spatial_layer(main_lakes_url)
states <- get_spatial_layer(states_url)
#provs <- get_spatial_layer(provs_url)
lakes_poly<-st_as_sf(main_lakes)
states_poly<-st_as_sf(states)
#provs_poly <- st_as_sf(provs) # provs pull is broken.

Inset <- ggplot()+
  geom_sf(data = states_poly,fill = "white")+
  #geom_sf(data = provs_poly,fill = "white")+
  geom_sf(data = lakes_poly,fill = "gray")+
    coord_sf( xlim = c(-95, -75),ylim = c(41, 50))+
  geom_point(data = LWF_genetic_masterlist_p, aes(x = Longitude, y = Latitude ), size = 2, alpha = .9)+
  geom_text_repel(data = LWF_genetic_masterlist_p, aes(x = Longitude, y = Latitude, label = WaterbodyName ), size = 5, point.padding = 10, min.segment.length=0, fontface="bold")+
  labs(x = "Longitude", y = "Latitude")+
  scale_color_aaas()+
  theme_classic()+
  theme(axis.text = element_text(size = 14, angle = 45, hjust = 1),
        axis.title = element_text(size = 16),
        legend.position = "none")
#ggsave("./Inset_p.tiff")



##JUST ERIE


Erie_p <- ggplot()+
  geom_sf(data = lakes_poly,fill = "gray")+
  coord_sf( xlim = c(-84, -78),ylim = c(41, 43))+
  geom_point(data = LWF_genetic_masterlist_p, aes(x = Longitude, y = Latitude), size = 3, alpha = .9)+
  geom_text_repel(data = LWF_genetic_masterlist_p, aes(x = Longitude, y = Latitude, label = WaterbodyName ), size = 3, point.padding = 10, min.segment.length=0, fontface="bold")+
  labs(x = "Longitude", y = "Latitude")+
  #scale_color_aaas()+
  theme_bw()+
  theme(axis.text = element_text(size = 14, angle = 45, hjust = 1),
        axis.title = element_text(size = 16),
        legend.position = "none")
ggsave("./Erie_p.tiff")
#plot_layer(main_lakes)





