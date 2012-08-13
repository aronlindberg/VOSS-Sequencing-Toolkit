# In order to generate the sequences I query bigquery.cloud.google.com
# as follows:
#
# SELECT type, created_at, repository_name FROM 
# [githubarchive:github.timeline]
# WHERE
# (created_at CONTAINS '2012-')
# AND repository_owner="twitter"
# ORDER BY created_at, repository_name;
#

#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/twitter_exploratory_analysis/")

#Load the TraMineR and cluster libraries
library(TraMineR)
library(cluster)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file
events.raw <- read.csv(file = "all_events.csv", header = TRUE)

#SO Solution

data.split <- split(events.raw$type, events.raw$repository_name)
data.split

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

twitter_sequences <- read.csv(file = "out.csv", header = TRUE)

# Turn this command on to get only the head of 1000

twitter_sequences <- head(twitter_sequences, 1000)

twitter_sequences_transposed <- t(twitter_sequences)

repo_names = colnames(twitter_sequences)

## Define the sequence object
twitter.seq <- seqdef(twitter_sequences_transposed, left="DEL", right="DEL", gaps="DEL", missing="")

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

# Next are optimal distance matching statistics
# But first we need to compute the OM

twitter_costs <- seqsubm(twitter.seq, method="TRATE")
twitter.om <- seqdist(twitter.seq, method="OM", indel=1, sm=twitter_costs, with.missing=FALSE)

# Create a dendrogram
clusterward <- agnes(twitter.om, diss = TRUE, method = "ward")
plot(clusterward, which.plots = 2, labels=colnames(twitter_sequences))

bannerplot(clusterward, labels=repo_names)

# Plot stuff
seqdplot(twitter.seq)

#Adjust margins
op <- par(mar = par("mar")/2)
# par(op)  ## tidy up to restore the default par setting

# Delete margin
op <- par(mar = rep(0, 4))

# Build a typology
cl1.4 <- cutree(clusterward, k = 10)
cl1.4fac <- factor(cl1.4, labels = paste(colnames(twitter_sequences), 1:10))

cl1.4fac <- factor(cl1.4,, 1:10)

seqdplot(twitter.seq, group = cl1.4fac, border = NA, space=0, use.layout=TRUE)

seqfplot(twitter.seq, group = cl1.4fac, border = NA)

## Representative set using the neighborhood density criterion
twitter.rep <- seqrep(twitter.seq, dist.matrix=twitter.om, criterion="density")