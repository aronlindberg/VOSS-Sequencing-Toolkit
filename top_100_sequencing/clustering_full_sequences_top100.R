# This is for processing the full sequencing. I need to do a full OM matrix between all the 100 sequences as wholes. Then I need to cluster them. Then I need to extract dummyvariables that indicate which cluster each project is a part of. Then these dummyvariables can be regressed on the GMM.

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/top_100_sequencing/")
#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)
library(stringr)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file

sequences <- read.csv(file = "event-stream-100-l.csv", header = TRUE, nrows=10)

# Turn this command on to get only the head of 100
sequences <- head(sequences, 100)

# Turn this on if you need to transpose the data
# sequences <- t(sequences)

repo_names = colnames(sequences)

# Turn this on if you want to drop the timestamp columns
# sequences <- sequences[, -grep("\\timestamps$", colnames(sequences))]


##################################################################

## Define the sequence object
sequences.seq <- seqdef(sequences, left="DEL", right="DEL", gaps="DEL", missing="")

## Summarize the sequence object
summary(sequences.seq)

## Mean Frequencies
seqmeant(sequences.seq)

## Frequency distributions for each sequence
seqistatd(sequences.seq)

# Transition rates
seqtrate(sequences.seq)

# Entropy
seqient(sequences.seq)

# Turbulence
seqST(sequences.seq)

# Complexity
seqici(sequences.seq)

# Next are optimal distance matching statistics
# But first we need to compute the OM
costs <- seqsubm(sequences.seq, method="TRATE")
sequences.om <- seqdist(sequences.seq, method="OM", indel=1, sm=costs, with.missing=FALSE, norm="maxdist")

# Create a dendrogram
clusterward <- agnes(sequences.om, diss = TRUE, method = "ward")
plot(clusterward, labels=colnames(sequences))




