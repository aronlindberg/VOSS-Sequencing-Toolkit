setwd("/Users/Aron/github/local/VOSS-Sequencing-Toolkit/msr_procedural_structure")

library(TraMineR)

sequences <- read.csv("rails_dataset.csv")

# To shorten it
sequences <- head(sequences, 15)

## Adding a ending time
sequences$end <- sequences$time

## max sequence length
slmax <- max(sequences$time)

sequences.sts <- seqformat(sequences, from="SPELL", to="STS", begin="time", 
      end="end", id="id", status="event", limit=slmax)

sequences.sts <- seqdef(sequences.sts)

# Fit PST model
library(PST)

## ===========================
## PST inluding missing states 
sequences.pst <- pstree(sequences.sts, L=3, nmin=1, ymin=0, 
      with.missing=TRUE)

# Prune the tree (reduce unwarranted complexity)
sequences.pruned <- prune(sequences.pst, L=3, nmin=2)
summary(sequences.pruned)

plot(sequences.pruned,
     nodePar=list(node.type="path", lab.type="prob", lab.pos=1, lab.offset=2, lab.cex=0.7, node.size=0.4),
     edgePar=list(type="triangle"),
     withlegend=FALSE
)

## =========================
## PST without missing states 
## in which case Lmax=2
sequences.pst <- pstree(sequences.sts, L=2, nmin=1, ymin=0, 
    with.missing=F)

# Prune the tree (reduce unwarranted complexity)
sequences.pruned <- prune(sequences.pst, L=3, nmin=2)
summary(sequences.pruned)

plot(sequences.pruned,
     nodePar=list(node.type="path", lab.type="prob", lab.pos=1, 
                  lab.offset=2, lab.cex=0.7, node.size=0.2),
     edgePar=list(type="triangle"),
     withlegend=FALSE
)

plot(sequences.pruned,
     nodePar=list(lab.cex=0.7, node.size=0.2, c.size=0.05),
     withlegend=FALSE
)
