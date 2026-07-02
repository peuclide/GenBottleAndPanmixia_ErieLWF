## ParaMask summary
library(vroom)
library(tidyverse)
list.files(pattern = "*het")

# Need to load ParaMask outputs from [IU Archive]

dat <- vroom("./ParaMask_Dec8/ErieWH_EMresults.finalClass.het")
head(dat)

sum(table(dat$EM_class))

dat %>% group_by(EM_class) %>% summarise(N=n(), Percent = n()/nrow(dat))
dat %>% group_by(allele.deviation.seed) %>% summarise(N=n(), Percent = n()/nrow(dat))
dat %>% group_by(finalClass) %>% summarise(N=n(), Percent = n()/nrow(dat))

whitelist <- dat %>% filter(allele.deviation.seed == 0) 
whitelist <- dat %>% filter(finalClass == 0) 

#vroom_write(whitelist, "./ErieWH_WL_final.txt")

bed <- vroom("./ParaMask_Dec8/ErieWH_EMresults.finalClass.bed")

bed %>% filter(`type:0-single-copy;1-multi-copy`==0) %>% summarise(sum(nSNPs))
bed %>% filter(`type:0-single-copy;1-multi-copy`==1) %>% summarise(sum(nSNPs))

bed1 <- bed %>% filter(Chromosome=="NC_059192.1")
bed2 <- bed %>% filter(Chromosome=="NC_059199.1")

ggplot(bed2 %>% filter(End <376004)) +
  geom_segment(aes(x = Start, xend = End,
                   y = Chromosome,
                   color = as.character(`type:0-single-copy;1-multi-copy`)),
               size = 2) +
  scale_color_manual(values = c("0" = "red", "1" = "gray")) +
  theme_minimal() +
  labs(x = "Position", y = NULL, color = "Duplicate") +
  theme(axis.ticks.y = element_blank())


ggplot(bed1, aes(x = End, y = nSNPs, color= as.character(`type:0-single-copy;1-multi-copy`)))+geom_point()

#### High het loci


ggplot(dat, aes(x = Heterozygous.geno.freq))+geom_density()
ggplot(whitelist, aes(x = Heterozygous.geno.freq))+geom_density()


ggplot(dat, aes(x = Heterozygous.geno.freq))+geom_density()+facet_wrap(~Chromosome)

ggplot(dat, aes(x = LLR))+geom_density()+facet_wrap(~Chromosome)

allHET <- dat %>% filter(Heterozygous.geno.freq>0.5)


dat %>% filter(EM_class==0) %>% ggplot(aes(x=Heterozygous.geno.freq, y = Het.allele.ratio))+geom_point()


dat %>% filter(EM_class==2) %>% ggplot(aes(x=Heterozygous.geno.freq, y = Het.allele.ratio))+geom_point()

dat  %>% ggplot(aes(x=Heterozygous.geno.freq, y = Het.allele.ratio, color = finalClass))+
geom_point(alpha = .1, size = 1)+theme_classic()


#### Per Chrom CLusters
beds <- list.files(path = "./ParaMask_Dec8/Clusters/", pattern = "bed")
hets <- list.files(path = "./ParaMask_Dec8/Clusters/", pattern = "het")
datComb <- NULL

for(i in beds){
  tmp <- vroom(paste0("./ParaMask_Dec8/Clusters/",i))
  datComb <- bind_rows(datComb, tmp)
}

deviants2 <- datComb %>% filter(`type:0-single-copy;1-multi-copy` == 1)
deviants2 %>% group_by(Chromosome) %>% summarise(SUM=sum(nSNPs))
deviants2 %>% summarise(SUM=sum(nSNPs))


hets <- list.files(path = "./ParaMask_Dec8/Clusters/", pattern = "het")
hetsComb <- NULL


for(i in hets){
  tmp <- vroom(paste0("./ParaMask_Dec8/Clusters/",i))
  hetsComb <- bind_rows(hetsComb, tmp)
}


whitelist1 <- hetsComb %>% filter(finalClass == 0) %>% select(Chromosome, Position)
#vroom_write(whitelist, "./ErieWH_WL_Dec11.txt")


ggplot(datComb) +
  geom_segment(aes(x = Start, xend = End,
                   y = Chromosome,
                   color = as.character(`type:0-single-copy;1-multi-copy`)),
               size = 2) +
  scale_color_manual(values = c("1" = "red", "0" = "gray")) +
  theme_minimal() +
  labs(x = "Position", y = NULL, color = "Duplicate") +
  theme(axis.ticks.y = element_blank())


