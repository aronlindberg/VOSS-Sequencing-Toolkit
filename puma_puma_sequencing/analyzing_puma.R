# In order to generate the sequences I query bigquery.cloud.google.com
# as follows:
#
# SELECT type, created_at, repository_watchers FROM [githubarchive:github.timeline]
# WHERE 
# (repository_name="android") AND
# (created_at CONTAINS '2012-') AND
# type !='WatchEvent'AND
# type !='ForkEvent'
# AND repository_owner="github"
# ORDER BY created_at;
#   

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/github_android_sequencing/")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file
events.raw <- read.csv(file = "android.csv", header = TRUE)

# Create a column for the months

events.raw$month      <- format(as.Date(events.raw$created_at), "%Y_%m")
events.raw$repo.month <- paste(events.raw$repository_name, events.raw$month, sep = "_")

# head(events.raw)

# Split up into columns per project/month

data.split <- split(events.raw$type, events.raw$repo.month)
# data.split

list.to.df <- function(arg.list) {
  max.len  <- max(sapply(arg.list, length))
  arg.list <- lapply(arg.list, `length<-`, max.len)
  as.data.frame(arg.list)
}

df.out <- list.to.df(data.split)
df.out

# Write to CSV to check
write.csv(df.out, file = "out.csv", quote = FALSE, na = "", row.names = FALSE)

## Load CSV file with raw sequence data

android_sequences <- read.csv(file = "out.csv", header = TRUE)

# Turn this command on to get only the head of 500
# twitter_sequences <- head(twitter_sequences, 500)

android_sequences_transposed <- t(android_sequences)

repo_names = colnames(android_sequences)

## Define the sequence object
android.seq <- seqdef(android_sequences_transposed, left="DEL", right="DEL", gaps="DEL", missing="")

## Summarize the sequence object
summary(android.seq)

## Mean Frequencies
seqmeant(android.seq)

## Frequency distributions for each sequence
seqistatd(android.seq)

# Transition rates
seqtrate(android.seq)

# Entropy
seqient(android.seq)

# Turbulence
seqST(android.seq)

# Complexity
seqici(android.seq)

# Next are optimal distance matching statistics
# But first we need to compute the OM
android_costs <- seqsubm(android.seq, method="TRATE")
android.om <- seqdist(android.seq, method="OM", indel=1, sm=android_costs, with.missing=FALSE, norm="maxdist")

dput(android.om, file = "events_om_object")

# Create a dendrogram
clusterward <- agnes(android.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2, labels=colnames(android_sequences))



