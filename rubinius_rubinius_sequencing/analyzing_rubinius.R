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
library(stringr)

# Direct output to a textfile
# sink("twitter_output.txt", append=FALSE, split=FALSE)

# To reset, use:
# sink(file = NULL)

## Load CSV file
events.raw <- read.csv(file = "input.csv", header = TRUE)

# Clean up time format
format(as.POSIXct(events.raw$created_at,format="%Y-%m-%dT17:%H:%M"),"%m/%d/%y %H:%M")

# Delete events called "Event" and "StatusEvent"
events.raw <- subset(events.raw, type!="Event")
events.raw <- subset(events.raw, type!="StatusEvent")
events.raw <- subset(events.raw, type!="PullRequestReviewCommentEvent")

# Create a new column that combines repository_name and month
events.raw$month      <- format(as.Date(events.raw$created_at), "%Y_%m")
events.raw$repo.month <- paste(events.raw$repository_name,
                               events.raw$month, sep = "_")

# Reformat the data

data.split <- split(events.raw$type, events.raw$repo.month)

list.to.df <- function(arg.list) {
  max.len  <- max(sapply(arg.list, length))
  arg.list <- lapply(arg.list, `length<-`, max.len)
  as.data.frame(arg.list)
}

df.out <- list.to.df(data.split)
head(df.out)

# Write to CSV to check
write.csv(df.out, file = "output.csv", quote = FALSE, na = "", row.names = FALSE)

## Load CSV file with raw sequence data

sequences <- read.csv(file = "output.csv", header = TRUE)

# Now, we need to create categories where there are email addresses (i.e month_actor_attributes_email). Below is the function that Hadley Wickham wrote that finds and replaces all.

replace_all <- function(df, pattern, replacement) {
  char <- vapply(df, function(x) is.factor(x) || is.character(x), logical(1))
  df[char] <- lapply(df[char], str_replace_all, pattern, replacement)  
  df
}

# Here are the function calls based on Tim's K-means clustering:

# Core committers
sequences <- replace_all(sequences, fixed("bford@engineyard.com"), "core")
sequences <- replace_all(sequences, fixed("brixen@gmail.com"), "core")
sequences <- replace_all(sequences, fixed("evan@fallingsnow.net"), "core")

# High committers
sequences <- replace_all(sequences, fixed("ephoenix@engineyard.com"), "core")
sequences <- replace_all(sequences, fixed("projects@kittensoft.org"), "high")
sequences <- replace_all(sequences, fixed("steve@steveklabnik.com"), "high")
sequences <- replace_all(sequences, fixed("jesse@jc00ke.com"), "high")
sequences <- replace_all(sequences, fixed("argentoff@gmail.com"), "high")
sequences <- replace_all(sequences, fixed("davis@engineyard.com"), "high")
sequences <- replace_all(sequences, fixed("tmornini@engineyard.com"), "high")

# Medium committers
sequences <- replace_all(sequences, fixed("d.bussink@gmail.com"), "medium")

# Low committers
# HERE YOU NEED TO FIND A WAY OF REPLACING ALL THE BLANKS IN THE ACTOR COLUMNS WITH "LOW".

# ALSO, I NEED A FUNCTION THAT REPLACES ALL UNKNOWN EMAIL ADDRESSES WITH "LOW".

# Write to CSV to check
write.csv(sequences, file = "output.csv", quote = FALSE, na = "", row.names = FALSE)


# Turn this command on to get only the head of 500
# twitter_sequences <- head(twitter_sequences, 500)

# Turn this on if you need to transpose the data
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


