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
sink("twitter_output.txt", append=FALSE, split=FALSE)

## Load CSV file with raw sequence data
twitter_sequences_transposed <- t(twitter_sequences <- read.csv(file = "twitter_events_mini.csv", header = TRUE))

## Define the sequence object
twitter.seq <- seqdef(twitter_sequences_transposed, left="DEL", right="DEL", gaps="DEL", missing="", id=c("commons", "finagle", "flockdb", "gizzard", "hoganjs", "mysql", "ostrich", "scalding", "twui", "zipkin"))

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
plot(clusterward, which.plots = 2, labels=c("commons", "finagle", "flockdb", "gizzard", "hoganjs", "mysql", "ostrich", "scalding", "twui", "zipkin"))

bannerplot(clusterward, labels=c("commons", "finagle", "flockdb", "gizzard", "hoganjs", "mysql", "ostrich", "scalding", "twui", "zipkin"))

# Plot stuff
seqdplot(twitter.seq)

#Adjust margins
op <- par(mar = par("mar")/2)
# par(op)  ## tidy up to restore the default par setting

# Delete margin
op <- par(mar = rep(0, 4))

# Build a typology
cl1.4 <- cutree(clusterward, k = 10)
cl1.4fac <- factor(cl1.4, labels = paste(c("commons", "finagle", "flockdb", "gizzard", "hoganjs", "mysql", "ostrich", "scalding", "twui", "zipkin"), 1:10))

cl1.4fac <- factor(cl1.4,, 1:10)

seqdplot(twitter.seq, group = cl1.4fac, border = NA, space=0, use.layout=TRUE)

seqfplot(twitter.seq, group = cl1.4fac, border = NA)

## Representative set using the neighborhood density criterion
twitter.rep <- seqrep(twitter.seq, dist.matrix=twitter.om, criterion="density")