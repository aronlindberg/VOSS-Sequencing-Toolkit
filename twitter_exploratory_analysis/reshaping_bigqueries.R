#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/twitter_exploratory_analysis/")

#Load the reshape package
library(reshape)

# Load CSV file with raw sequence data
events.raw <- read.csv(file = "all_events.csv", header = TRUE)

# Mini version
events.raw <- head(read.csv(file = "all_events.csv", header = TRUE, colClasses = "character"), 100)

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

# Define the sequence object

events.seq <- seqdef(df.out)