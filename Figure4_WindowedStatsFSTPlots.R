## Window FST plot -- angsd

## Purpose:

## 1) Read windowed FST output files

## 2) Calculate z-scores for FST within each subfacet/chromosome

## 3) Identify zFST outliers

## 4) Build a Manhattan-style plot

## 5) Overlap zFST outlier windows with selscan xp-EHH outlier regions

## 6) Highlight overlapping windows on the plot

library(ggplot2)
library(tidyverse)
library(vroom)
library(GenomicRanges)

###### PLOT FUNCTION

## Purpose:

## Create the base Manhattan-style zFST plot.

## - Alternating chromosome colors

## - Outlier windows highlighted in a different color

## - Horizontal threshold line at zFST = 6

ManPlot <- function(x, y, grp){
  ggplot()+
    # Optional older plotting logic retained for reference:
    # geom_point(data = plot_data %>% filter(OutlierFlag ==FALSE), aes(x  = BPcum, y = -log10(qvalues), color = ChrOrdered), size = 2, alpha = 0.5)+
    # geom_point(data =  plot_data %>% filter(OutlierFlag ==TRUE), aes(x = BPcum, y = -log10(qvalues)), color = "red", size = 2, alpha = 0.5)+
    
    
    # Main genome-wide zFST points
    geom_point(data = x, aes(x  = BPcum, y = ZFst, color = ChrOrdered), size = 1, alpha = 0.5)+
    
    # Highlight zFST outliers
    geom_point(data =  x %>% filter(index %in% fstsOuts$index), aes(x = BPcum, y = ZFst), color = "#FFA319FF", size = 1, alpha = 0.5)+
    
    # Alternating chromosome colors for Manhattan layout
    scale_color_manual(values = rep(c("#155F83FF", "#767676FF"), nCHR)) +
    
    # Chromosome labels placed at chromosome centers
    scale_x_continuous(label = y$ChrOrdered, breaks = y$center) +
    
    # zFST significance threshold
    geom_hline(yintercept = 6, color = "#FFA319FF")+
    
    #labs(x = "Scaffold", title=grp)+
    theme_classic()+
    theme(legend.position = "none")
  
  
}

#####

## STEP 1: Read and combine windowed FST files

## Purpose:

## Load all chromosome-specific FST output files into one data frame.

FSTs <- list.files("./data/ManPlotData", pattern = "MyRes_Dec-21-25", full.names = T)

fsts_WGS <- NULL
for(file in FSTs[1:40]){
  CHROM=gsub("./data/ManPlotData/MyRes_Dec-21-25_","",file)
  CHROM=gsub("_sig200-step50_SNP_fst.txt","", CHROM)
  print(CHROM)
  fsts <- vroom(file)
  fsts$CHR=CHROM
  fsts_WGS <- rbind(fsts_WGS,fsts)
}

unique(fsts_WGS$CHR)

## STEP 2: Standardize chromosome ordering and create plotting index

## Purpose:

## Convert chromosome IDs to numeric order and assign each row a unique index.

# re-order factor levels for region

fsts_WGS$chr <- as.numeric(as.factor(fsts_WGS$CHR))

# index for plotting

fsts_WGS$index <- 1:nrow(fsts_WGS)

## STEP 3: Calculate zFST values and multiple-testing adjusted p-values

## Purpose:

## Standardize FST within each subfacet/chromosome and identify extreme values.

fsts_WGS <- fsts_WGS %>%
  group_by(subfacet, chr) %>%
  mutate(ZFst= (fst-mean(fst, na.rm = T))/sd(fst, na.rm = T),
         pval = pnorm(ZFst,lower.tail=FALSE),
         BHp = p.adjust(pval, method = 'BH'))

## STEP 4: Define zFST outliers

## Purpose:

## Keep windows with high zFST and enough SNPs to support the signal.

# set threshold for outliers - we used ZFst>= 6

fstsOuts <- fsts_WGS %>% group_by(chr) %>% filter(ZFst >= 6 & n_snps >= 10)
#write.table(fstsOuts,"ZFstOutliers.txt")

############################################################

## BRANCH A: Erie-only plot and overlap with selscan XP-EHH

############################################################

## STEP 5A: Restrict to the comparison group of interest

## Purpose:

## Remove subfacets not relevant to the Erie comparison.

# Only TRNR, MB, and LP

#fsts_WGS_Erie <- fsts_WGS %>% filter(!subfacet %in% grep("CR|DR|CB", value = T, fsts_WGS$subfacet))
fsts_WGS_Erie <- fsts_WGS %>% filter(!grepl("CR|DR|CB", subfacet))

#fstsOuts_Erie <- fstsOuts%>% filter(!subfacet %in% grep("CR|DR|CB", value = T, fstsOuts$subfacet))
fstsOuts_Erie <- fstsOuts %>% filter(!grepl("CR|DR|CB", subfacet))

## STEP 6A: Prepare plotting data

## Purpose:

## Keep only the columns needed for the Manhattan plot and order chromosomes.

plot_data <- fsts_WGS_Erie %>% select("CHR","index", "position","fst", "ZFst")

plot_data <- fsts_WGS_Erie %>% select("CHR","index", "position","fst", "ZFst")
plot_data$chr <- as.numeric(as.factor(plot_data$CHR))
#plot_data$Chr <- gsub("_*", "", plot_data$Chr)
plot_data <- plot_data %>% arrange(as.numeric(chr)) %>% mutate(ChrOrdered = as.factor(as.numeric(chr)))

## STEP 7A: Convert physical positions to cumulative genome positions

## Purpose:

## Make the x-axis continuous across chromosomes for a Manhattan-style layout.

nCHR <- length(unique(plot_data$ChrOrdered))
plot_data$BPcum <- NA
s <- 0
nbp <- c()
for (i in unique(plot_data$ChrOrdered)){
  nbp[i] <- max(plot_data[plot_data$ChrOrdered == i,]$position)
  plot_data[plot_data$ChrOrdered == i,"BPcum"] <- plot_data[plot_data$ChrOrdered == i,"position"] + s
  s <- s + nbp[i]
}

## STEP 8A: Define x-axis tick positions

## Purpose:

## Place chromosome labels at the midpoint of each chromosome segment.

axis.set <- plot_data %>%
  group_by(ChrOrdered) %>%
  summarize(center = (max(BPcum) + min(BPcum)) / 2)

axis.set <- axis.set[seq(from=1, to=40,by=2),]

p_WestEast <- ManPlot(plot_data, axis.set, grp = "West - East")
p_WestEast
#ggsave("./ErieWh_WestEast.png")

### STEP 9A: Overlap zFST outlier windows with selscan XP-EHH outlier regions

## Purpose:

## Identify zFST outliers that fall inside selscan outlier intervals.

# ## make end position for windowed outs

fstsOuts_Erie <- fstsOuts_Erie %>% mutate(pos.end = position+49999)

## SELSCAN DATA

## Purpose:

## Load selscan outlier intervals for the Erie comparison sets.

EW_data <- read.table("./data/ManPlotData/XPEHHManPlot-lp-trnr_outliers.txt", header =T)
EW_data$chr <- as.numeric(as.factor(EW_data$LG))
WW_data <- read.table("./data/ManPlotData/XPEHHManPlot-mb-trnr_outliers.txt", header =T)
WW_data$chr <- as.numeric(as.factor(WW_data$LG))

## STEP 10A: Split zFST outliers by comparison category

## Purpose:

## Create candidate zFST windows for the two selscan comparisons.

## EW overlap

ZfstsEW <- fstsOuts_Erie %>% select(subfacet, index, chr, position, pos.end, ZFst, fst)
ZfstsEW <- ZfstsEW %>% filter(subfacet%in% grep("LP", value = T, ZfstsEW$subfacet)& subfacet !="LP~MB")

ZfstsWW <- fstsOuts_Erie %>% select(subfacet, index, chr, position, pos.end, ZFst, fst)
ZfstsWW <- ZfstsWW %>% filter(!subfacet%in% grep("LP", value = T, ZfstsWW$subfacet )& subfacet !="NR~TR")

## STEP 11A: Define an overlap function

## Purpose:

## Convert both tables to GenomicRanges, find interval overlaps, and tag rows as overlapping or not.

SetOverlap <- function(Zfst, Selscan){
  gr.z=makeGRangesFromDataFrame(Zfst, keep.extra.columns = TRUE,ignore.strand = FALSE, seqnames.field = c("chr","chromosome"),start.field = "position",end.field = "pos.end",strand.field = "strand")
  gr.ew=makeGRangesFromDataFrame(Selscan, keep.extra.columns = TRUE,ignore.strand = FALSE, seqnames.field = c("chr","chromosome"),start.field = "start",end.field = "end",strand.field = "strand")
  z.ew=findOverlaps(gr.z,gr.ew, select="all",ignore.strand=FALSE)
  ##subsection data for existing outliers
  outliersz.ew=c(z.ew@from)
  z2=Zfst[outliersz.ew,]
  z2$outliers="yes"
  
  ##subsection data that are not outliers
  z3=Zfst[-outliersz.ew,]
  z3$outliers="no"
  
  ##combine subsections and reorganize data
  z4=rbind(z3,z2)
  z4=z4[with(z4,order(chr, subfacet, position)),]
  print(z4)
}

## STEP 12A: Run overlap detection for the two Erie comparisons

## Purpose:

## Extract only the zFST outlier windows that overlap selscan regions.

## East to West

EW_Overlap <- SetOverlap(ZfstsEW, EW_data)
EW_Overlap <- EW_Overlap %>% filter(outliers=="yes")
dim(EW_Overlap)

## West to West

WW_Overlap <- SetOverlap(ZfstsWW, WW_data)
WW_Overlap <- WW_Overlap %>% filter(outliers=="yes")
dim(WW_Overlap)

## STEP 13A: Add overlap highlights to the Manhattan plot

## Purpose:

## Overlay the zFST windows that intersect selscan XP-EHH outlier regions.

#### Figure 4 b

p_WestEastFinal <- p_WestEast+
  geom_point(data =  plot_data %>% filter(index%in% EW_Overlap$index ), aes(x = BPcum, y = ZFst), color = "green", size = 3, alpha = 0.5)+
  geom_point(data =  plot_data %>% filter(index%in%WW_Overlap$index ), aes(x = BPcum, y = ZFst), color = "purple", size = 2, alpha = 0.5)+
  scale_y_continuous(breaks = c(0,2,4,6,8))+
  labs(x= "Chromosome", y = expression("ZF"[ST]))+
  theme(axis.text.x = element_text(size = 6))
p_WestEastFinal
#ggsave("Figure4_ErieWh_WestEast_selscanOverlap.tiff", height = 3, width = 7.5, units = "in")

## STEP 14A: Export overlap windows

## Purpose:

## Save the windows that overlap selscan regions for downstream use.

OverlapOutliers_ErieToErie <- fsts_WGS %>% filter(index %in% c(EW_Overlap$index, WW_Overlap$index))
OverlapOutliers_ErieToErie <- OverlapOutliers_ErieToErie %>% mutate(pos.end = position+49999)
OverlapOutliers_ErieToErie <- OverlapOutliers_ErieToErie %>% select(CHR, position, pos.end)

#write.table(OverlapOutliers_ErieToErie, "./OverlapOutliers_ErieToErie.bed", quote = F, row.names = F, sep = "\t")

############################################################

## BRANCH B: Erie vs Huron plot and overlap with selscan XP-EHH

############################################################

## STEP 5B: Restrict to the Erie-Huron comparison

## Purpose:

## Remove subfacets not relevant to the Erie/Huron comparison.

###### --------------------------------

## CR to TRNR

## Only TRNR and CR

#fsts_WGS_EH <- fsts_WGS %>% filter(!subfacet %in% grep("DR|CB|MB|LP", value = T, fsts_WGS$subfacet))
fsts_WGS_EH <- fsts_WGS %>% filter(!grepl("DR|CB|MB|LP", subfacet))

fsts_WGS_EH <- fsts_WGS_EH%>% filter(!subfacet %in% c("NR~TR"))

#fstsOuts_EH <- fstsOuts%>% filter(!subfacet %in% grep("DR|CB|MB|LP", value = T, fstsOuts$subfacet))
fstsOuts_EH <- fstsOuts %>% filter(!grepl("DR|CB|MB|LP", subfacet))

fstsOuts_EH <- fstsOuts_EH%>% filter(!subfacet %in% c("NR~TR"))

## STEP 6B: Prepare plotting data

## Purpose:

## Build the subset used for the Erie-Huron Manhattan plot.

plot_data <- fsts_WGS_EH %>% select("CHR","index", "position","fst", "ZFst")
plot_data$chr <- as.numeric(as.factor(plot_data$CHR))
#plot_data$Chr <- gsub("_*", "", plot_data$Chr)
plot_data <- plot_data %>% arrange(as.numeric(chr)) %>% mutate(ChrOrdered = as.factor(as.numeric(chr)))

#plot_data <- plot_data %>% select("FST", "qvalues", "OutlierFlag", "ChrOrdered", "position")

## Continuous position

nCHR <- length(unique(plot_data$ChrOrdered))
plot_data$BPcum <- NA
s <- 0
nbp <- c()
for (i in unique(plot_data$ChrOrdered)){
  nbp[i] <- max(plot_data[plot_data$ChrOrdered == i,]$position)
  plot_data[plot_data$ChrOrdered == i,"BPcum"] <- plot_data[plot_data$ChrOrdered == i,"position"] + s
  s <- s + nbp[i]
}

## STEP 7B: Define x-axis tick positions

## Purpose:

## Same cumulative-coordinate setup as above for the Erie-Huron comparison.

## define axis ticks

axis.set <- plot_data %>%
  group_by(ChrOrdered) %>%
  summarize(center = (max(BPcum) + min(BPcum)) / 2)

axis.set <- axis.set[seq(from=1, to=40,by=2),]

p_WestHuron <- ManPlot(plot_data, axis.set, grp = "West - East")
p_WestHuron
#ggsave("./ErieWh_WestEast.png")

## STEP 8B: Prepare zFST outlier windows for overlap testing

## Purpose:

## Expand each outlier window so it can be intersected with selscan intervals.

## make end position for windowed outs

fstsOuts_EH <- fstsOuts_EH %>% mutate(pos.end = position+49999)

## STEP 9B: Load selscan XP-EHH intervals

## Purpose:

## Read the Erie-Huron comparison outlier list.

## SELSCAN DATA

HW_data <- read.table("./data/ManPlotData/XPEHHManPlot-cr-trnr_outliers.txt", header = T)
HW_data$chr <- as.numeric(as.factor(HW_data$LG))

### STEP 10B: Overlap zFST outliers with selscan regions

## Purpose:

## Identify windows that overlap the selscan outlier regions.

### overlap with Selscan

Zfsts <- fstsOuts_EH %>% select(subfacet, index, chr, position, pos.end, ZFst, fst)

gr.z=makeGRangesFromDataFrame(Zfsts, keep.extra.columns = TRUE,ignore.strand = FALSE, seqnames.field = c("chr","chromosome"),start.field = "position",end.field = "pos.end",strand.field = "strand")
gr.ew=makeGRangesFromDataFrame(HW_data, keep.extra.columns = TRUE,ignore.strand = FALSE, seqnames.field = c("chr","chromosome"),start.field = "start",end.field = "end",strand.field = "strand")

##

z.ew=findOverlaps(gr.z,gr.ew, select="all",ignore.strand=FALSE)

##the integers indicate the rows that overlap within the data files, i.e 6 indicates row 6 of first set of data input
##use to check if overlap is correct

str(z.ew)
z.ew@from
Zfsts[6,]
#ew[13,]

##subsection data for existing outliers

outliersz.ew=c(z.ew@from)
z2=Zfsts[outliersz.ew,]
z2$outliers="yes"

##subsection data that are not outliers

z3=Zfsts[-outliersz.ew,]
z3$outliers="no"

##combine subsections and reorganize data

z4=rbind(z3,z2)
z4=z4[with(z4,order(chr, subfacet, position)),]

### summary

z4 %>% group_by(outliers) %>% summarise(n(), meanFST = mean(fst))

##saving file as a txt file
#write.table(z4,file="ZFstOutliersforErieHuron.txt",row.names=TRUE,col.names=TRUE)

fstsOuts_EH <- fstsOuts_EH %>% select(chr, subfacet, position, position, pos.end, index, fst, ZFst, BHp)
#write.table(fstsOuts_EH, "./ZFstOutliersERIE_HURON.txt")

## Erie to Huron

#write.table(overlap, "./OutlersOverlap_selscan-ZFst_lp-trnr.txt", quote = F, row.names = F, sep = "\t")

#### Figure 4 A

## STEP 11B: Keep only overlapping outliers for the final highlight

## Purpose:

## Plot only windows that are shared between the zFST scan and selscan outlier regions.

z4 <- z4 %>% filter(outliers=="yes")
p_WestHuronFinal <- p_WestHuron+
  geom_point(data =  plot_data %>% filter(index%in% z4$index ), aes(x = BPcum, y = ZFst), color = "green", size = 3, alpha = 0.5)+
  scale_y_continuous(breaks = c(0,2,4,6,8))+
  labs(x= "Chromosome", y = expression("ZF"[ST]))+
  theme(axis.text.x = element_text(size = 6))

#ggsave("Figure4_ErieWh_WestEast_selscanOverlap.tiff", height = 3, width = 7.5, units = "in")

## STEP 12B: Combine final comparison plots

## Purpose:

## Stack the two final Manhattan-style plots into one figure.

ggpubr::ggarrange(p_WestHuronFinal, p_WestEastFinal, ncol = 1, nrow = 2, labels = c("A", "B"))
#ggsave("Figure4_ErieWh_WestEast_selscanOverlap.tiff", height = 7.5, width = 7.5, units = "in")

## STEP 13B: Export Erie-Huron overlap windows

## Purpose:

## Save the shared overlap windows as BED-like coordinates for downstream analysis.

OverlapOutliers_ErieToHuron <- fsts_WGS %>% filter(index %in% z4$index)
OverlapOutliers_ErieToHuron <- OverlapOutliers_ErieToHuron %>% mutate(pos.end = position+49999)
OverlapOutliers_ErieToHuron <- OverlapOutliers_ErieToHuron %>% select(CHR, position, pos.end)

#write.table(OverlapOutliers_ErieToHuron, "./OverlapOutliers_ErieToHuron.bed", quote = F, row.names = F, sep = "\t")

#mean(OverlapOutliers_ErieToHuron$fst)
