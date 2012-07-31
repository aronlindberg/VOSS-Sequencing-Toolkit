# In order to generate the sequence I query bigquery.cloud.google.com
# as follows:
#
# SELECT type FROM [githubarchive:github.timeline]
# WHERE repository_name="commons"
# AND repository_owner="twitter"
#
# and
# 
# SELECT type FROM [githubarchive:github.timeline]
# WHERE repository_name="bootstrap"
# AND repository_owner="twitter"
#
# The commons project has 355 watchers and the bootstrap project has 34,402 watchers.
# Hence, they are clearly very different in popularity. Can we see any differences in the sequences of these two projects?



#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/twitter_exploratory_analysis/")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

## Load CSV file with raw sequence data
commons_sequences <- read.csv(file = "commons_sequences.csv", header = FALSE)
bootstrap_sequences <- read.csv(file = "bootstrap_sequences.csv", header = FALSE)

## Define the sequence object
commons.seq <- seqdef(commons_sequences)
bootstrap.seq <- seqdef(bootstrap_sequences)

## Summarize the sequence object
summary(commons.seq)
summary(bootstrap.seq)

## Calculate various statistics
seqmeant(commons.seq)
seqmeant(bootstrap.seq)

seqtrate(commons.seq)
seqtrate(bootstrap.seq)

seqient(commons.seq)
seqient(bootstrap.seq)

seqST(commons.seq)
seqST(bootstrap.seq)

# Longest common subsequence
seqLLCS(commons.seq, bootstrap.seq)