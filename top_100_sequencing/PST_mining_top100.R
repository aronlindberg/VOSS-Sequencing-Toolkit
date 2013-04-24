# This is for processing the full sequencing. I need to do a full OM matrix between all the 100 sequences as wholes. Then I need to cluster them. Then I need to extract dummyvariables that indicate which cluster each project is a part of. Then these dummyvariables can be regressed on the GMM.

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/top_100_sequencing/")
#Load the TraMineR and cluster libraries
library(TraMineR)
library(PST)
library(cluster)
library(stringr)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file

sequences <- read.csv(file = "event-stream-100-l.csv", header = TRUE, nrows=50)

# Turn this command on to get only the head of 100
# sequences <- head(sequences, 100)

# Turn this on if you need to transpose the data
sequences <- t(sequences)

# Turn this on to get only 10 sequences
sequences <- head(sequences, 10)

# repo_names = colnames(sequences)

# Turn this on if you want to drop the timestamp columns
# sequences <- sequences[, -grep("\\timestamps$", colnames(sequences))]


##################################################################

## Define the sequence object
sequences.seq <- seqdef(sequences, left="DEL", right="DEL", gaps="DEL", missing="")

# Fit PST model
sequences.pst <- pstree(sequences.seq)

# Mine patterns
sequences.pm <- pmine(sequences.pst, sequences.seq, pmin=0.4, output='patterns')
