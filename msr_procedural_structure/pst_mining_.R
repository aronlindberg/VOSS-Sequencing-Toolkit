# This is for processing GHTorrent Rails example data

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/msr_procedural_structure/")
#Load the TraMineR and cluster libraries
library(TraMineR)
library(TraMineRextras)
library(PST)
library(cluster)
library(stringr)
library(VLMC)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load data file

sequences <- read.delim(file = "rails_data.txt", header = FALSE, sep = ",", nrow=100)

# Turn this command on to get only the head of 100
# sequences <- head(sequences, 100)

# Turn this on if you need to transpose the data
# sequences <- t(sequences)

# Turn this on to get only 10 sequences
# sequences <- head(sequences, 10)

# Fix column names
colnames(sequences) <- c("id", "time", "event")

# Convert time column to actual dates
sequences$time <- as.POSIXct(sequences$time, origin="1970-01-01 00:00:01")

# DO SIMPLE EVENT MINING
## Define the event sequence object (for descriptives)
sequences2 <- head(sequences, 50)

sequences.seqe <- seqecreate(sequences2, id = sequences2$id, timestamp = sequences2$time,event = sequences2$event)

# Displaying the data
print(sequences.seqe)
seqpcplot(sequences.seqe)

# Find most frequent subsequences
mostfreq <- seqefsub(sequences.seqe, pMinSupport = 0.05)

plot(mostfreq[1:10]) # display the 10 most common subsequences

# Filter out single event sequences
mostfreq2 <- seqentrans(mostfreq)
mostfreq3 <- mostfreq2[mostfreq2$data$nevent > 1]
plot(mostfreq3[1:10]) # display the 10 most common subsequences with > 1 events

# 4. Exctracting sequential association rules
DO THIS NEXT, and then email Georgios and ask for more data, richer alphabet, and covariates.
# 5. Dissimilarity-based analysis of event sequences

# 2. Covariates
# 2.5 Entropy?
# 3. Finding most discriminate subsequences for covariates

# FITTING USING VLMC
sequences <- as.character(sequences)

sequences.vlmc <- vlmc(sequences)

# FITTING USING PST
# Convert to STS
sequences.sts <- TSE_to_STS(sequences, id = 1, timestamp = 2, event = 3, tmax = 10)
sequences.sts <- seqdef(sequences.sts)

# sequences <- as.data.frame(sequences)

# Fit PST model
sequences.pst <- pstree(sequences.sts, L=20, nmin=30)

# Mine patterns
sequences.pm <- pmine(sequences.pst, sequences.seq, pmin=0.4, output='patterns')

data(s1)
s1.seq <- seqdef(s1)
s1.seq
S1 <- pstree(s1.seq, L = 3)
print(S1, digits = 3)
S1
