#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

## Load CSV file with raw sequence data
git_sequences <- read.csv(file = "GitSequences.csv", header = TRUE)

## Building one channel per aspect

actor <- git_sequences$Actor
activity <- git_sequences$Activity
object <- git_sequences$Design.Object
io <- git_sequences$Input.Output

## Building sequence objects 
actor.seq <- seqdef(actor) 
activity.seq <- seqdef(activity) 
object.seq <- seqdef(object) 
io.seq <- seqdef(io)

## Using transition rates to compute substitution costs on each channel 
mcdist <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq),
                    method="OM", sm =list("TRATE", "TRATE", "TRATE", "TRATE")) 	 

## Specifying weights for channels and specifying substitution-cost 
smatrix <- list() 
smatrix[[1]] <- seqsubm(actor.seq, method="CONSTANT") 
smatrix[[2]] <- seqsubm(activity.seq, method="CONSTANT") 
smatrix[[3]] <- seqsubm(object.seq, method="CONSTANT") 
smatrix[[4]] <- seqsubm(io.seq, method="CONSTANT")
mcdist2 <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq), method="OM", sm =smatrix, cweight=c(1,1,1,1)) 

# Plot a dendrogram
clusterward <- agnes(mcdist2, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2)

#Create an **ordinary** sequence object
github.seq <- seqdef(mcdist2)

# Plot common sequences
seqfplot(github.seq)


