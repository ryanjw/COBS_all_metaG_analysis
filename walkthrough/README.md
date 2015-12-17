##COBS metaG multivariate walkthrough

[nmds]: https://raw.githubusercontent.com/ryanjw/COBS_all_metaG_analysis/master/walkthrough/nmds.jpg


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

Go into the R environment and read in the data with ``read.table()``...it'll go something like this
```
dataset<-read.table("...path\to\file...", sep="\t",header=TRUE)
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


##Nonmetric multidimensional scaling##
![alt text][nmds]
