### WH pca

# Packages
library(ggplot2)
library(readxl)
library(tidyverse)
library(ggsci)

# Color palette setup
UchiPal <- pal_uchicago("default", alpha =1)(9)
scales::show_col(UchiPal)

cb="#155F83FF"
cr="#767676FF"
dr="#FFA319FF"
lp="#8A9045FF"
mb="#800000FF"
nr="#C16622FF"
pi="#8F3931FF"  
tr="#58593FFF"
ws="#350E20FF"

UchiPal_mod <- c(dr, mb, nr, tr, pi, ws, cb, lp, cr)
scales::show_col(UchiPal_mod)


#----------------------------
#### -------- GT-seq -----------
#----------------------------

# Read PCA results and accompanying metadata
d <- read.table("./data/GTseq_Jun-10-25_All_PCA1-10.txt", sep = "\t", header = T)
d$sampleID <- gsub(",", "", d$sampleID)
d$genepop_pop <- gsub(",", "", d$genepop_pop)
#d$id <- gsub("-B_R1", "", d$id)
#d$id <- gsub("_R1", "", d$id)

lod <- read.table("./data/GTseq_Jun-10-25_All_PCA1-10_lod.txt")
metad <- read.csv("./data/popmap.csv")

# Join sample PCA data to metadata and remove missing rows
d <- d %>% left_join(metad, by = c("sampleID" = "IND")) %>% drop_na()

# Set plotting order for populations and basins
d$POP <- factor(d$POP, levels = c("Detroit River", "Maumee Bay", "Niagara Reef", "Toussaint Reef","Pelee Island", "West Sister","Fairport Harbor", "Long Point", "Coreyon Reef"))
d$BASIN <- factor(d$BASIN, levels = c("West Basin", "Central Basin", "East Basin", "Lake Huron"))

# GT-seq PCA plot
p1 <- ggplot(d, aes(x = PC1, y = PC2, color = POP, shape = BASIN))+
  geom_point(size = 3, alpha = .75)+
  scale_color_manual(values = UchiPal_mod)+
  labs(x = "PC1 - 3.4%", y = "PC2 - 2.7%", shape = "Basin", color = "Sampling site")+
  theme_bw()+theme(text = element_text(size = 14))
p1


#### ERIE only

# Read Erie-only PCA results and metadata
d <- read.table("./data/GTseq_Jun-10-25_Erie_PCA1-10.txt", sep = "\t", header = T)
d$sampleID <- gsub(",", "", d$sampleID)
d$genepop_pop <- gsub(",", "", d$genepop_pop)
d[d$pop=="Central_Basin",3] <- "Fairport Harbor"
#d$id <- gsub("-B_R1", "", d$id)
#d$id <- gsub("_R1", "", d$id)

lod <- read.table("./data/GTseq_Jun-10-25_Erie_PCA1-10_lod.txt")

# Join to metadata and remove missing rows
d <- d %>% left_join(metad, by = c("sampleID" = "IND")) %>% drop_na()

# Set plotting order for Erie populations and basins
d$POP <- factor(d$POP, levels = c("Detroit River", "Maumee Bay", "Niagara Reef", "Toussaint Reef","Pelee Island", "West Sister","Fairport Harbor", "Long Point"))
d$BASIN <- factor(d$BASIN, levels = c("West Basin", "Central Basin", "East Basin"))

# Erie-only GT-seq PCA plot
p2 <- ggplot(d, aes(x = PC1, y = PC2, color = POP, shape = BASIN))+
  geom_point(size = 3, alpha = .75)+
  scale_color_manual(values = UchiPal_mod)+
  labs(x = "PC1 - 2.8%", y = "PC2 - 2.3%", shape = "Basin", color = "Sampling site")+
  theme_bw()+theme(text = element_text(size = 14))
p2

# Combine GT-seq PCA panels
ggpubr::ggarrange(p1, p2, labels = c("A", "B"), common.legend = T, legend = "right")
#ggsave("./GTseq_PCAs.png")


#----------------------------
#### -------- WGS -----------
#----------------------------

# Read WGS PCA results and loadings
dAll <- read.delim("./data/WGS_Dec-16-25_AllPCA1-10.txt", sep = "\t")
loadings <- read.table("./data/WGS_Dec-16-25_AllPCA1-10_lod.txt", header = T)

# Manually assign basin and collection labels in the same order as the PCA file
dAll$basin <-  c(rep("Central Basin", 6), rep("Lake Huron", 15), rep("West Basin",8), rep("East Basin",40), rep("West Basin",58))
dAll$collection <-  c(rep("Fairport Harbor", 6), rep("Coreyon Reef", 15), rep("Detroit River",8), rep("Long Point",40), rep("Maumee Bay",20),rep("Niagara Reef",23), rep("Toussaint Reef",15))

# Optional factor-ordering lines retained for reference
#dAll$pop <- factor(dAll$pop, levels = c("CR","DR", "MB", "NR", "TR", "CB", "LP"))
#dAll$collection <- factor(dAll$collection, levels = c("Coreyon Reef","Detroit River", "Maumee Bay", "Niagara Reef", "Toussaint Reef", "Central Basin", "Long Point"))
#dAll$basin <- factor(dAll$basin, levels = c("Lake Huron","West Basin", "Central Basin", "East Basin"))

dAll$basin <- factor(dAll$basin, levels = c("West Basin", "Central Basin", "East Basin", "Lake Huron"))

# Prepare WGS data for plotting
pData <- dAll
pData$collection <- factor(pData$collection, levels = c("Detroit River", "Maumee Bay", "Niagara Reef", "Toussaint Reef", "Fairport Harbor", "Long Point", "Coreyon Reef"))
pData$basin <- factor(pData$basin, levels = c("West Basin", "Central Basin", "East Basin", "Lake Huron"))

# WGS palette order for this panel
UchiPal_mod <- c(dr, mb, nr, tr, cb, lp, cr)

# Inspect PCA loadings table
head(loadings)

# WGS all-samples PCA plot
p3 <- ggplot(pData, aes(x = PC1, y = PC2, color = collection, shape = basin))+
  geom_point(size = 3, alpha = .75)+
  scale_color_manual(values = UchiPal_mod)+
  labs(x = paste0("PC1 - ",loadings$lod[1],"%"), y = paste0("PC2 - ",loadings$lod[2],"%"), shape = "Basin", color = "Sampling site")+
  theme_bw()+theme(text = element_text(size = 14))
p3


#### ERIE only

# Read Erie-only WGS PCA results and loadings
dErie <- read.delim("./data/WGS_Dec-16-25_AllEriePCA1-10.txt", sep ="\t")
loadingsErie <- read.table("./data/WGS_Dec-16-25_AllEriePCA1-10_lod.txt", header = T)

# Manually assign basin and collection labels in the same order as the Erie-only PCA file
dErie$basin <-  c(rep("Central Basin", 6), rep("West Basin",8), rep("East Basin",40), rep("West Basin",58))
dErie$collection <-  c(rep("Fairport Harbor", 6),  rep("Detroit River",8), rep("Long Point",40), rep("Maumee Bay",20),rep("Niagara Reef",23), rep("Toussaint Reef",15))
#

dErie$basin <- factor(dErie$basin, levels = c("West Basin", "Central Basin", "East Basin"))

# Prepare Erie-only WGS data for plotting
pData <- dErie
pData$collection <- factor(pData$collection, levels = c("Detroit River", "Maumee Bay", "Niagara Reef", "Toussaint Reef", "Fairport Harbor", "Long Point"))
pData$basin <- factor(pData$basin, levels = c("West Basin", "Central Basin", "East Basin"))

# Erie-only WGS PCA plot
p4 <- ggplot(pData, aes(x = PC1, y = PC2, color = collection, shape = basin))+
  geom_point(size = 3, alpha = .75)+
  scale_color_manual(values = UchiPal_mod)+
  labs(x = paste0("PC1 - ",loadingsErie$lod[1],"%"), y = paste0("PC2 - ",loadingsErie$lod[2],"%"), shape = "Basin", color = "Sampling site")+
  theme_bw()+theme(text = element_text(size = 14))
p4



############ Figure 2 #####

# Arrange all four PCA panels into a single figure
ggpubr::ggarrange(p1, p2, p3, p4, ncol = 2, nrow=2, common.legend = T, labels = c("A","B","C","D"), legend = "right")
# ggsave("./Figure2_PCAs.tiff", width = 8, height = 6)
# ggsave("./Figure2_PCAs.tiff", width = 8, height = 6)
# ggsave("./Figure2_PCAs.png", width = 8, height = 6)

