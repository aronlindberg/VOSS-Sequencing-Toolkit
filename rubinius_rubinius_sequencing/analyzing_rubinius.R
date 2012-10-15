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
df <- read.csv(file = "rubinius_6months.csv", header = TRUE)

# split df by month
by.mon <- split(df, months(as.POSIXct(df$created_at)))

# sort by month
by.mon <- by.mon[order(match(names(by.mon), month.name))]

# rename the columns to include the month name
by.mon <- mapply(
  function(x, mon.name) {
    names(x) <- paste(mon.name, names(x), sep='_');
    return(x)
  }, x=by.mon, mon.name=names(by.mon), SIMPLIFY=FALSE)

# add an index column for merging on
by.mon.indexed <- lapply(by.mon, function(x) within(x, index <- 1:nrow(x)))

# merge all of the months together
results <- Reduce(function(x, y) merge(x, y, by='index', all=TRUE, sort=FALSE), 
                  by.mon.indexed)

# remove the index column
final_result <- results[names(results) != 'index']

# Write to CSV to check
write.csv(final_result, file = "output.csv", quote = FALSE, na = "", row.names = FALSE)

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
# HERE YOU NEED TO FIND A WAY OF REPLACING ALL THE BLANKS IN THE ACTOR COLUMNS WITH "LOW"

# Write to CSV to check
write.csv(sequences, file = "output.csv", quote = FALSE, na = "", row.names = FALSE)


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


