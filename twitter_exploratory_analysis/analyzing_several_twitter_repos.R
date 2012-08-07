# In order to generate the sequence I query bigquery.cloud.google.com
# as follows:
#
# SELECT type, created_at FROM [githubarchive:github.timeline]
# WHERE 
#   (repository_name="put_repo_name_here") AND
#   (created_at CONTAINS '2012-')
# AND repository_owner="twitter"
# ORDER BY created_at
#

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/twitter_exploratory_analysis/")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

## Load CSV file with raw sequence data
twitter_sequences_transposed <- t(twitter_sequences <- read.csv(file = "twitter_events_mini.csv", header = TRUE))

## Define the sequence object
twitter.seq <- seqdef(twitter_sequences_transposed)

## Summarize the sequence object
summary(twitter.seq)

## Frequencies
seqmeant(twitter.seq)

# Transition rates
seqtrate(twitter.seq)

# Entropy
seqient(twitter.seq)

# Turbulence
seqST(twitter.seq)

# Complexity
seqici(twitter.seq)

# Longest common subsequence
seqLLCS(twitter.seq)

# Next are optimal distance matching statistics
# But first we need to compute the OM

twitter_costs <- seqsubm(twitter.seq, method="TRATE")
twitter.om <- seqdist(twitter.seq, method="OM", indel=1, sm=twitter_costs, with.missing=FALSE)

# Create a dendrogram
clusterward <- agnes(twitter.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2)

# Plot stuff
seqdplot(twitter.seq)

## Representative set using the neighborhood density criterion
twitter.rep <- seqrep(twitter.seq, dist.matrix=twitter.om, criterion="density")