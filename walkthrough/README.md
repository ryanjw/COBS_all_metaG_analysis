##COBS metaG multivariate walkthrough

[nmds]: https://raw.githubusercontent.com/ryanjw/COBS_all_metaG_analysis/master/walkthrough/nmds.jpg
[pcoa_no_arrows]: https://raw.githubusercontent.com/ryanjw/COBS_all_metaG_analysis/master/walkthrough/pcoa_no_arrows.jpg

We are going to walkthrough some basic multivariate analysis that can help with analyzing metagenomes and any other multivariate dataset.

Our goals are to:

1. Learn basic multivariate analyses

2. Use R both remotely and locally

3. Produce publication-ready visualizations

4. Generate multivariate statistics

##Getting Started##
- Navigate to anl5 and the path
```
ssh anl5
cd /mnt/data1/rjw_COBS_analysis/COBS_all_metaG_analysis/data
```
Now we will run R by simply typing ``R``

We are now in a remote R environment.  Think of this as your 'data crunching space', while we will use R on our local machine as our 'studio'.

##Reading in the data##

Look at the dataset before going into R (in other words type ``quit()`` if you are currently in the R environment).  There are a variety of ways to do this.

What do you notice about this file?  How is it organized?  How is it delimited?

Go into the R environment and read in the data with ``fread()`` from the `data.table` library...it'll go something like this
```
library(data.table)
dataset<-fread("COBS_round1_metaG_mgrast_annotation_data_matrix.txt",sep="\t",header=TRUE, data.table=FALSE)
```
Look at a subset of the data using `head()`, `tail()`, `str()`, and `dim()`.  Select a subset of the data using indexes like this
```
# I want only the first five rows and columns 10 through 15
dataset[1:5,10:15]
```
##Our first visualization##
We will first look at how similar our samples are to one another through a visualization called non-metric multidimensional scaling (NMDS).  This visualization tries to represent the similarity between samples in a reduced number of dimensions.

We will first do this based on relative abundance within each sample, note that this can be done in other ways...
```
library(vegan)
dataset_trans<-decostand(dataset[,-c(1:5)],"total")
nmds<-metaMDS(dataset_trans, k=2, method="bray", autotransform=FALSE)

# Note that you can nest these functions
nmds<-metaMDS(decostand(dataset[,-c(1:5)],"total"),k=2,method="bray",autotransform=FALSE)

```
There are several ways to plot this...we are going to use the ggplot2 library to produce a plot in our 'studio'.

First, we want to pull out the cartesian coordinates for the nmds (where in 2d space these points exist)
```
# notice that I am putting all the metadata in a dataframe with the scores so I can use this information in the plot
results<-data.frame(dataset[,1:5],scores(nmds))
write.table(".../path/to/write/to...",sep="\t",row.names=F)
```
Now before we plot this NMDS, let's try to get some quantitative ideas about what we should expect to see.

Are differences between aggregates significant? -> using PERMANOVA aka ``adonis()``
More specifically, in N-dimensions, are groups of samples distinct?
```
adonis(decostand(dataset[,-c(1:5)],"total")~dataset$SoilFrac, strata=dataset$block)

```
Are some aggregates more variable than one another? -> using tests of beta diversity aka ``betadisper()``
```
b_results<-betadisper(decostand(dataset[,-c(1:5)],"total"),"median")
anova(b_results)
TukeyHSD(b_results)
```
We have some idea now of how things should look.  

Now we are going to copy this securely to our local machine with ``scp``.
Go into your terminal and do this command

```
scp anl5:/path/to/nmds/results/ ~/path/i/want/it/at/on/local/machine
```
Now we are going to open R on our local machine and plot.

```
# read in the ggplot2 library
library(ggplot2)
#read in the data
nmds_info<-read.table("/path/to/nmds/stuff", sep="\t", header=TRUE)
ggplot(mds)+geom_point(aes(x=NMDS1,y=NMDS2,colour=SoilFrac))+theme(aspect.ratio=1)
```

Is this what we expect?

If not, how can we fix it?

##Nonmetric multidimensional scaling##
Now we are going to make a fancier NMDS like we are trying to get a pub or impress our friends (or both)
```
# read in this additional library
library(RColorBrewer)
```
It would be nice to shade in areas between points so we can see which groups of samples 'own' that space.  We will do this using ``chull()``.  If you pass this function a series of points, it will create a shape with these points and return all of those that are on the outside edges.

```
# We can do this simply
micro_hull<-nmds[nmds$SoilFrac=="Micro",][chull(nmds[nmds$SoilFrac=="Micro",c("NMDS1","NMDS2")]),]

#or we can do this in one loop
hull_data<-data.frame()
for(i in 1:length(unique(nmds$SoilFrac))){
	new_row<-nmds[nmds$SoilFrac==as.vector(unique(nmds$SoilFrac)[i]),][chull(nmds[nmds$SoilFrac==as.vector(unique(nmds$SoilFrac)[i]),c("NMDS1","NMDS2")]),]
	hull_data<-rbind(hull_data,new_row)
}
```
Though this loop looks complicated, it only really involves subsetting and applying the ``chull()`` function...not that dange`R`ous.

Now some organizational stuff
```
nmds$SoilFrac<-factor(nmds$SoilFrac,levels=c("Micro","SM","MM","LM","WS"))
levels(nmds$SoilFrac)<-c("Micro","Small","Medium","Large","Whole Soil")

hull_data$SoilFrac<-factor(hull_data$SoilFrac,levels=c("Micro","SM","MM","LM","WS"))
levels(hull_data$SoilFrac)<-c("Micro","Small","Medium","Large","Whole Soil")
```
What color palette would we like?
```
display.brewer.all(n=5)
```

Earlier we made a figure with only set of data, but now we have two (nmds and hull_data).  I am going to show you how to do this in a piece-wise manner.
```
#just the points alone
ggplot()+geom_point(data=mds,aes(x=NMDS1,y=NMDS2,shape=SoilFrac,colour=SoilFrac),size=4)
# just the hulls alone
ggplot()+geom_polygon(data=hull_data,aes(x=NMDS1,y=NMDS2,fill=SoilFrac,group=SoilFrac),alpha=0.3)
#putting them together is easy
ggplot()+geom_polygon(data=hull_data,aes(x=NMDS1,y=NMDS2,fill=SoilFrac,group=SoilFrac),alpha=0.3)+geom_point(data=mds,aes(x=NMDS1,y=NMDS2,shape=SoilFrac,colour=SoilFrac),size=4)
```
Let's pretty it up
```
ggplot()+geom_polygon(data=hull_data,aes(x=NMDS1,y=NMDS2,fill=SoilFrac,group=SoilFrac),alpha=0.3)+geom_point(data=mds,aes(x=NMDS1,y=NMDS2,shape=SoilFrac,colour=SoilFrac),size=4)+theme_bw(base_size=20)+theme(aspect.ratio=1)+scale_colour_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_fill_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_shape_discrete(name="Soil\nFraction")
```
We had those statistics for the PERMANOVA, let's show put it in the plot so that the visualization is paired with quantitative info.
```
ggplot()+geom_polygon(data=hull_data,aes(x=NMDS1,y=NMDS2,fill=SoilFrac,group=SoilFrac),alpha=0.3)+geom_point(data=mds,aes(x=NMDS1,y=NMDS2,shape=SoilFrac,colour=SoilFrac),size=4)+theme_bw(base_size=20)+theme(aspect.ratio=1)+scale_colour_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_fill_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_shape_discrete(name="Soil\nFraction")+annotate("text",x=.25,y=.175,label="R[italic(pseudo)]^{2}==0.273~italic(P)==0.004",parse=TRUE)
```

![alt text][nmds]

##Principal coordinates analysis##

We may also want to look at which groups of variables are changing the most across the samples and are therefore potentially driving differences between groups of samples.  One way to do this is Principal coordinates analysis (PCoA).  This is a distance-based approach; therefore there are less assumptions needed for the data than Principal Components Analysis (PCA).  Instead, if you do a PCoA with euclidian distance, it is identical to PCA.  IMO you should do a PCoA only since PCA can essentially be a special case of PCoA.  

So lets get to it...we are going to use the ``capscale()`` function from the `vegan()` library

```
pcoa<-capscale(decostand(dataset[,-c(1:5)],"total")~1,dist="bray")
```
Now we are going to do something similar to the NMDS steps by extracting `scores` from the `pcoa` object

```
pcoa_sites<-data.frame(dataset[,1:5],scores(pcoa)$sites)
pcoa_species<-data.frame(rownames(scores(pcoa)$species),scores(pcoa)$species)
```
Note that there are `sites`, which refer to the location of points while `species` refer to the head of a vector representing the direction of variation for a particular variable originating from (0,0)

We can also figure out how much variance is explained in each orthogonal dimension (e.g. axis 1, axis 2, etc.)
```
var_explained<-eigenvals(pcoa)/sum(eigenvals(pcoa))
```
If we look at this object, we can see how much variance is explained in each direction

Let's make hulls and organize as we did previously
```
hull_data_pcoa<-data.frame()
for(i in 1:length(unique(pcoa_sites$SoilFrac))){
	new_row<-pcoa_sites[pcoa_sites$SoilFrac==as.vector(unique(pcoa_sites$SoilFrac)[i]),][chull(pcoa_sites[pcoa_sites$SoilFrac==as.vector(unique(pcoa_sites$SoilFrac)[i]),c("MDS1","MDS2")]),]
	hull_data_pcoa<-rbind(hull_data_pcoa,new_row)
}

pcoa_sites$SoilFrac<-factor(pcoa_sites$SoilFrac,levels=c("Micro","SM","MM","LM","WS"))
levels(pcoa_sites$SoilFrac)<-c("Micro","Small","Medium","Large","Whole Soil")

hull_data_pcoa$SoilFrac<-factor(hull_data_pcoa$SoilFrac,levels=c("Micro","SM","MM","LM","WS"))
levels(hull_data_pcoa$SoilFrac)<-c("Micro","Small","Medium","Large","Whole Soil")
```

Now plot it
```
ggplot()+geom_polygon(data=hull_data_pcoa,aes(x=MDS1,y=MDS2,fill=SoilFrac,group=SoilFrac),alpha=0.3)+geom_point(data=pcoa_sites,aes(x=MDS1,y=MDS2,shape=SoilFrac,colour=SoilFrac),size=4)+theme_bw(base_size=15)+theme(aspect.ratio=1)+scale_colour_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_fill_manual(name="Soil\nFraction",values=brewer.pal(5,"Dark2"))+scale_shape_discrete(name="Soil\nFraction")+labs(x="MDS1 (35% var. explained)",y="MDS2 (16% var. explained)")
```
![alt text][pcoa_no_arrows]

We can also determine how much variation is explained by specific experimental factors.  This is Constrained Analysis of Principal Coordinates (CAP) (similar to something called Redundancy Analysis (RDA))
```
pcoa<-capscale(decostand(dataset[,-c(1:5)],"total")~dataset$SoilFrac,dist="bray")
summary(pcoa)
anova(pcoa,strata=dataset$block)
anova(pcoa)
# Note the difference when including block
```
Clearly there is something up with these Medium samples, does anyone know how to figure out why?  Any ideas?

#Next steps
1. Deal with Medium issue
2. Repeat analyses
3. Find out what's driving the relationships
