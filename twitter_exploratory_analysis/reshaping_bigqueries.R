#Set the working directory
setwd("~/github/local/VOSS-Sequencing-Toolkit/twitter_exploratory_analysis/")

#Load the reshape package
library(reshape)

# Load CSV file with raw sequence data
events.raw <- read.csv(file = "all_events.csv", header = TRUE)

# Mini version
mini.events.raw <- head(read.csv(file = "all_events.csv", header = TRUE, colClasses = "character"), 100)

m.mini.events <- melt.data.frame(mini.events.raw, id.vars = c("repository_name", "type", "created_at"))

cast(m.mini.events, created_at ~ repository_name | .)
 

# Melt the CSV
m.events.raw <- melt(events.raw)


# Cast it differently
cast(m.events.raw, type ~ repository_name, length)

cast(m.events.raw, repository_name ~ created_at ~ type)

cast(m.events.raw, value=repository_name + type) 

(m.events.raw <- cbind(m.events.raw, colsplit(m.events.raw$variable, names = c("treatment", "time"))))