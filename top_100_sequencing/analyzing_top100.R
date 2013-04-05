# I need to be able to do 2 things: 1) sequence all 100 repos in relation to others so that I can cluster repos-as-wholes for the entire time period (I already know how to do this, I just need the data and to be able to do it on the cluster) 2) Create a function that sequences the months for each repo in turn, to create a matrix where every row is a month, every column is a repo, and every value is the evolutionary rate for month t compared to month t-1. Hence I need to loop through repo by repo and sequence the various months against each other to generate an OM matrix, then extract the standardized (%) distances from that matrix and put them in the output matrix. The values I am interested in are just above the diagonal [1,2 - 2,3 - 3,4]

# Plan to actually do this
# 1. Isolate components of code
# 2. Ask questions about each on SO
# Components: 
# 1. Looping across 10 columns at a time
# 2. Extract the diagonal (one step above diagonal) from the matrix
# 3. Write the matrix as a column
# 4. Make sure the column is correctly sorted

# data <- read.csv(file = "data.csv", header="TRUE")

# For the first n to n+9 columns # The first 10 columns are different months of the same project, and should be sequences against each other, the 2nd 10 are for a second project and should be sequenced against each other...all the way to the 100th project (1000th column)
# START
# data.seq <- seqdef(data$n to n+9) # Define a sequence object out of the first 10 columns
# data.om <- seqdist(data.seq) # Write the OM distances between those columns to an object
# write.csv(diag(data.om), file = "OM_distances") # Write the diagonal to a column (earliest month on top, later months below)
# n+9 # Move to columns 11-20 and repeat the process, then do 21-30 etc., all the way to the 100th project and the 1000th column
# GOTO START

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

sequences <- read.csv(file = "event-stream-20-l-m.csv", header = TRUE, nrows=10)

# Turn this command on to get only the head of 100
# twitter_sequences <- head(twitter_sequences, 100)

# Turn this on if you need to transpose the data
# sequences_transposed <- t(sequences)

repo_names = colnames(sequences)

# Turn this on if you want to drop the timestamp columns
# sequences <- sequences[, -grep("\\timestamps$", colnames(sequences))]

# Loop across 10 columns at a time

## Loop across and define the sequence object
colpicks <- seq(10,240,by=10)
sequence_objects <- mapply(function(start,stop) seqdef(sequences[,start:stop]), colpicks-9, colpicks)

# Next are optimal distance matching statistics
# But first we need to compute the OM
costs <- mapply(function(start,stop) seqsubm(sequence_objects[,start:stop], method="TRATE"), colpicks-9, colpicks)

sequences.om <- seqdist(sequences.seq, method="OM", indel=1, sm=costs, with.missing=FALSE, norm="maxdist")

## Loop through OM distances and save the superdiagonal

offd <- cbind(1:9,2:10) # For 10 sequences
sequences.om[offd]


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

# print frequences & OM-distances to CSV
write.csv(seqistatd(sequences.seq), file = "stats.csv", quote = FALSE, na = "", row.names = TRUE)

write.csv(sequences.om, file = "OM-distances2.csv", quote = FALSE, na = "", row.names = TRUE)

# print diversity measures to the same file
write.csv(data.frame(entropy=seqient(sequences.seq), complexity=seqici(sequences.seq), turbulence=seqST(sequences.seq)), file = "diversity_measures.csv", quote = FALSE, na = "", row.names = TRUE)


dput(sequences.om, file = "events_om_object")

dput(sequences.seq, file = "sequences.seq_object")


# Create a dendrogram
clusterward <- agnes(sequences.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2, labels=colnames(sequences))


