#Set working directory to be one directory out from GitHub repo

setwd("./COBS_all_metaG_analysis/")
source("./libraries.R")

dataset<-read.table("/mnt/data1/jin_mapping/Bowtie2/COBSMappedRound1/result/normal_counts.txt",sep="\t",header=T)
# remove one contig that had a length of 0
dataset<-subset(dataset, Length > 0)
# removing last column which is blank
dataset<-dataset[,-dim(dataset)[2]]

#removing low quality samples
dataset<-dataset[,-c(47:50,40,43:45)]

# performing test first for differences of aggregates within FP (all aggregates and whole soil)
ags<-dataset[,c(1:3,32,41,34,38,7:10,33,30,31,37,28:29,42,36,40,35,47,39)]

# making a column to subselect by how often a variable shows up, then subsetting out singletons
ags$counts<-rowSums(decostand(ags[,-c(1:3)],"pa"))
ags_nosing<-subset(ags, counts >= 4)

# transposing into a matrix
ags_t<-t(ags_nosing[,-c(2,3,20)])
colnames(ags_t)<-ags_t[1,]

#making it a data.frame
ags_df<-data.frame(ags_t)
ags_df<-cbind(rownames(ags_df),ags_df)
names(ags_df)[1]<-"Sample"

