
###

## GONE2 replicate Ne trajectories and change-through-time plots

## Purpose:

## - Read 10 GONE2 replicate output files for each lake

## - Combine Erie and Huron replicate Ne estimates into one data frame

## - Add metadata to distinguish lake, replicate, and grouping

## - Create a smoothed summary Ne trajectory

## - Define time windows for fishing history and abundance declines

## - Plot Ne through time and the change in Ne between generations

## - Compare the final Erie and Huron change-in-Ne profiles

library(ggplot2)
library(tidyverse)
library(zoo)
library(tidyquant)
library(strucchange)
library(scales)

##### GONE 2

# Data generated from GONE2 in 10 replicate runs using a random subset of loci

g2_e1 <- read.table("./data/GONE2_output/rep1.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e2 <- read.table("./data/GONE2_output/rep2.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e3 <- read.table("./data/GONE2_output/rep3.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e4 <- read.table("./data/GONE2_output/rep4.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e5 <- read.table("./data/GONE2_output/rep5.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e6 <- read.table("./data/GONE2_output/rep6.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e7 <- read.table("./data/GONE2_output/rep7.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e8 <- read.table("./data/GONE2_output/rep8.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e9 <- read.table("./data/GONE2_output/rep9.er.filtered_data.ped_GONE2_Ne", header = T)
g2_e10 <- read.table("./data/GONE2_output/rep10.er.filtered_data.ped_GONE2_Ne", header = T)

g2_c1 <- read.table("./data/GONE2_output/rep1.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c2 <- read.table("./data/GONE2_output/rep2.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c3 <- read.table("./data/GONE2_output/rep3.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c4 <- read.table("./data/GONE2_output/rep4.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c5 <- read.table("./data/GONE2_output/rep5.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c6 <- read.table("./data/GONE2_output/rep6.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c7 <- read.table("./data/GONE2_output/rep7.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c8 <- read.table("./data/GONE2_output/rep8.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c9 <- read.table("./data/GONE2_output/rep9.cr.filtered_data.ped_GONE2_Ne", header = T)
g2_c10 <- read.table("./data/GONE2_output/rep10.cr.filtered_data.ped_GONE2_Ne", header = T)

# Combine all replicate outputs into one long table

# Each row is tagged by lake, group, and replicate number

combinedg2 <- bind_rows(g2_e1 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 1),
                        g2_e2 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 2),
                        g2_e3 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 3),
                        g2_e4 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 4),
                        g2_e5 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 5),
                        g2_e6 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 6),
                        g2_e7 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 7),
                        g2_e8 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 8),
                        g2_e9 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 9),
                        g2_e10 %>% mutate(lake = "Erie", lake_group = "500k Subset g2", rep = 10),
                        
                        
                        g2_c1 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 1),
                        g2_c2 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 2),
                        g2_c3 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 3),
                        g2_c4 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 4),
                        g2_c5 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 5),
                        g2_c6 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 6),
                        g2_c7 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 7),
                        g2_c8 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 8),
                        g2_c9 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 9),
                        g2_c10 %>% mutate(lake = "Huron", lake_group = "500k Subset g2", rep = 10)
                        
                        
)

# Add a date-like version of generation and compute a rolling average of Ne

# The rolling window smooths short-term noise across nearby generations

combinedg2.2 <- combinedg2 %>% mutate(GenYear= as.Date(Generation)) %>%
  group_by(lake) %>%
  tq_mutate(select=Ne_diploids, mutate_fun = rollapply, width = 10, align="right", FUN = mean, na.rm=T, col_rename = "rollAve")

# Summarize the replicate Ne values at each generation by lake

# Mean Ne is used for the heavy summary line

# Confidence intervals summarize replicate variability

Combinedsummaryg2 <- combinedg2 %>%  group_by(lake, Generation) %>% summarise(meanNe = mean(Ne_diploids),
                                                                              lower_ci = t.test(Ne_diploids, conf.level = 0.95)$conf.int[1],
                                                                              upper_ci = t.test(Ne_diploids, conf.level = 0.95)$conf.int[2])

## Set fishing history

# Define the generation windows corresponding to fishing history and abundance declines

# These are used to shade the plot and add text annotations

early_fishing=(2025-1800)/4
lowAbun1Start <- (2025-1890)/4
lowAbun1End<- (2025-1907)/4
lowAbun2Start <- (2025-1948)/4
lowAbun2End<- (2025-1995)/4
LittleIceAgeStart <- (2025-1570)/4
LittleIceAgeEnd <- (2025-1900)/4

#### Plot of NE

# Plot replicate-level Ne values with lake-specific point shapes

# Overlay the lake-level mean Ne trajectory

p2 <- ggplot(combinedg2.2, aes(x = Generation, y = Ne_diploids, shape = lake)) +
  geom_vline(xintercept = early_fishing, linetype=2)+
  geom_rect(aes(xmin = lowAbun1Start, xmax = lowAbun1End, ymin = 0, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_rect(aes(xmin = lowAbun2Start, xmax = lowAbun2End, ymin = 0, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_point(size = .75, alpha = .75) +
  geom_line(data=Combinedsummaryg2, aes(x = Generation, y = meanNe, linetype = lake), color = "firebrick", alpha = .85, size = 1)+
  scale_y_log10(guide = "axis_logticks", labels = label_comma())+
  scale_shape_manual(values = c("Huron" = 3, "Erie" = 16)) +  # 16: filled circle, 3: plus
  labs(x = "Generations Before Present", y = "Geometric Mean Ne", color = "Data")+
  theme_bw() +
  annotate("text", x = early_fishing+2, y = 1e+03, label = "Early Fishing", angle = 90)+
  annotate("text", x = lowAbun1Start-(lowAbun1Start-lowAbun1End)/2, y = 1e+03, label = "1st Decline", angle = 90)+
  annotate("text", x = lowAbun2Start-(lowAbun2Start-lowAbun2End)/2, y = 1e+03, label = "2nd Decline", angle = 90)+
  labs(color = "Locus-set", shape = "Lake Point Estimate", linetype = "Lake Mean")+
  theme(text = element_text(size = 10),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 13),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 14),
        legend.position = c(0.85, 0.75)  # (x, y) in [0,1] relative coordinates
  )
p2

# ggsave("./Figure_3_GONE_ne_Huron+Erie_g2.tiff", width = 10, height = 5, units = "in")

# ggsave("./Figure_3_GONE_ne_Huron+Erie_g2.png", width = 10, height = 5, units = "in")

## fold change from peak

# Quick summary check for Erie mean Ne across generations

Combinedsummaryg2 %>% filter(lake =="Erie") %>% summarise(max(meanNe), first(meanNe))

FoldChange=15994/3685

# Prepare Erie mean trajectory for breakpoint analysis

erieMean <- Combinedsummaryg2 %>% filter(lake =="Erie")

# Estimate structural breakpoints in Erie Ne history

erieBP <- breakpoints(erieMean$meanNe~1, breaks = 5)
plot(erieBP)
ci_erieBP <- confint(erieBP, breaks = 3)

# Prepare Huron mean trajectory for breakpoint analysis

huronMean <- Combinedsummaryg2 %>% filter(lake =="Huron")

# Estimate structural breakpoints in Huron Ne history

huronBP <- breakpoints(huronMean$meanNe~1, breaks = 5)
plot(huronBP)
ci_huronBP <- confint(huronBP, breaks = 1)

### Change in NE plot

# Calculate generation-to-generation change in Ne within each lake and replicate

# lag(Ne_diploids) gives the previous generation’s Ne, and the difference gives change magnitude

combinedg2.2 <- combinedg2.2 %>% group_by(lake, rep) %>% mutate(Net=lag(Ne_diploids)-Ne_diploids)

# Plot change in Ne for Huron

# geom_smooth() adds a smoothed trend across replicate points

p3 <- ggplot(combinedg2.2 %>% filter(lake =="Huron"), aes(x = Generation, y = Net, shape = lake)) +
  geom_vline(xintercept = early_fishing, linetype=2)+
  geom_rect(aes(xmin = lowAbun1Start, xmax = lowAbun1End, ymin =  0, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_rect(aes(xmin = lowAbun2Start, xmax = lowAbun2End, ymin = 0, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_point(size = .75, alpha = .75) +
  geom_smooth()+
  scale_y_log10(guide = "axis_logticks", labels = label_comma())+
  scale_shape_manual(values = c("Huron" = 3, "Erie" = 16)) +  # 16: filled circle, 3: plus
  labs(x = "Generations Before Present", y = "Change in Ne", color = "Data")+
  theme_bw() +
  annotate("text", x = early_fishing+2, y = 1, label = "Early Fishing", angle = 90)+
  annotate("text", x = lowAbun1Start-(lowAbun1Start-lowAbun1End)/2, y = 1, label = "1st Decline", angle = 90)+
  annotate("text", x = lowAbun2Start-(lowAbun2Start-lowAbun2End)/2, y = 1, label = "2nd Decline", angle = 90)+
  labs(color = "Locus-set", shape = "Lake Point Estimate", linetype = "Lake Mean")+
  theme(text = element_text(size = 10),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 13),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 14),
        legend.position = c(0.8, 0.7)  # (x, y) in [0,1] relative coordinates
  )
p3

# Plot change in Ne for Erie using the same layout and annotation scheme

p4 <- ggplot(combinedg2.2 %>% filter(lake =="Erie"), aes(x = Generation, y = Net, shape = lake)) +
  geom_vline(xintercept = early_fishing, linetype=2)+
  geom_rect(aes(xmin = lowAbun1Start, xmax = lowAbun1End, ymin = -Inf, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_rect(aes(xmin = lowAbun2Start, xmax = lowAbun2End, ymin = -Inf, ymax = Inf), fill = "gray", alpha =.025, color =NA)+
  geom_point(size = .75, alpha = .75) +
  geom_smooth()+
  scale_shape_manual(values = c("Huron" = 3, "Erie" = 16)) +  # 16: filled circle, 3: plus
  labs(x = "Generations Before Present", y = "Change in Ne", color = "Data")+
  theme_bw() +
  annotate("text", x = early_fishing+2, y = 500, label = "Early Fishing", angle = 90)+
  annotate("text", x = lowAbun1Start-(lowAbun1Start-lowAbun1End)/2, y = 500, label = "1st Decline", angle = 90)+
  annotate("text", x = lowAbun2Start-(lowAbun2Start-lowAbun2End)/2, y = 500, label = "2nd Decline", angle = 90)+
  labs(color = "Locus-set", shape = "Lake Point Estimate", linetype = "Lake Mean")+
  theme(text = element_text(size = 10),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 13),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 14),
        legend.position = c(0.8, 0.3)  # (x, y) in [0,1] relative coordinates
  )
p4

# Combine the Erie and Huron change-in-Ne panels into one figure

ggpubr::ggarrange(p4, p3, nrow = 2, ncol = 1, labels = c("A", "B"))
#ggsave("./Figure_supplement_GONE_ne_Huron+Erie_g2.tiff", width = 10, height = 10, units = "in")
