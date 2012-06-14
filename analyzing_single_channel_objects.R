#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

## Load CSV file with raw sequence data
activity_sequences <- read.csv(file = "ActivitySequences.csv", header = TRUE)

## Define the sequence object
activity.seq <- seqdef(activity_sequences)

## Summarize the sequence object
summary(activity.seq)

## Calculate various statistics
seqtab(activity.seq)
seqstatd(activity.seq)
seqmeant(activity.seq)
seqmodst(activity.seq)
seqtrate(activity.seq)
seqient(activity.seq)
seqST(activity.seq)

## Create various plots
seqiplot(activity.seq)
seqIplot(activity.seq)
seqfplot(activity.seq)
seqHtplot(activity.seq)