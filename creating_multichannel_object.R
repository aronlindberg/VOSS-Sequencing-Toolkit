#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

## Load CSV file with raw sequence data
git_sequences <- read.csv(file = "GitSequences.csv", header = FALSE)

## Building one channel per aspect

actor <- git_sequences[1,]
activity <- git_sequences[2,]
object <- git_sequences[3,]
io <- git_sequences[5,]

## Building sequence objects 
actor.seq <- seqdef(actor) 
activity.seq <- seqdef(activity) 
object.seq <- seqdef(object) 
io.seq <- seqdef(io)

## Using transition rates to compute substitution costs on each channel 
mcdist <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq), method="HAM", sm =list("CONSTANT", "CONSTANT", "CONSTANT", "CONSTANT")) 	 

## Specifying weights for channels and specifying substitution-cost 
smatrix <- list() 
smatrix[[1]] <- seqsubm(actor.seq, method="CONSTANT") 
smatrix[[2]] <- seqsubm(activity.seq, method="CONSTANT") 
smatrix[[3]] <- seqsubm(object.seq, method="CONSTANT") 
smatrix[[4]] <- seqsubm(io.seq, method="TRATE")
mcdist2 <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq), method="HAM", sm =smatrix, cweight=c(1,1,1,1)) 

# Plot a dendrogram
clusterward <- agnes(mcdist2, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2)