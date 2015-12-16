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


##Nonmetric multidimensional scaling##
![alt text][nmds]
