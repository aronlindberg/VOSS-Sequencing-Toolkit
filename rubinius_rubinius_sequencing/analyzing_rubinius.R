# In order to generate the sequences I query bigquery.cloud.google.com
# as follows:
#
# SELECT gt1.type, gt1.created_at, gt1.repository_owner, gt1.repository_name, 
# gt1.actor_attributes_email, gt1.actor_attributes_login, gt1.actor_attributes_name
# FROM [githubarchive:github.timeline] as gt1
# INNER JOIN (
#   SELECT actor_attributes_login 
#   FROM [githubarchive:github.timeline]
#   WHERE (type = "ForkEvent" OR type = "PublicEvent") AND
#   repository_owner = "rubinius" AND
#   repository_name = "rubinius"
# ) as gt2
# ON gt2.actor_attributes_login == repository_owner
# WHERE gt1.repository_name="rubinius" AND
# gt1.type != "WatchEvent"
# ORDER BY gt1.created_at, gt1.repository_name;
#   

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/rubinius_rubinius_sequencing/")
#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file
events.raw <- read.csv(file = "input.csv", header = TRUE)

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
write.csv(df.out, file = "output.csv", quote = FALSE, na = "", row.names = FALSE)

## Load CSV file with raw sequence data

sequences <- read.csv(file = "output.csv", header = TRUE)

# Turn this command on to get only the head of 500
# twitter_sequences <- head(twitter_sequences, 500)

sequences_transposed <- t(sequences)

repo_names = colnames(sequences)

## Define the sequence object
sequences.seq <- seqdef(sequences_transposed, left="DEL", right="DEL", gaps="DEL", missing="")

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

dput(sequences.om, file = "events_om_object")

# Create a dendrogram
clusterward <- agnes(sequences.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2, labels=colnames(sequences))


