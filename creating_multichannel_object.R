## Load CSV file with raw sequence data

## Building one channel per aspect
actor
activity
object
io

children <-  bf==4 | bf==5 | bf==6 
married <- bf == 2 | bf== 3 | bf==6 
left <- bf==1 | bf==3 | bf==5 | bf==6 
## Building sequence objects 
actor.seq <- seqdef(actor) 
activity.seq <- seqdef(activity) 
object.seq <- seqdef(object) 
io.seq <- seqdef(io)

## Using transition rates to compute substitution costs on each channel 
mcdist <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq),
                    method="OM", sm =list("TRATE", "TRATE", "TRATE")) 	 
## Using a weight of 2 for children channel and specifying substitution-cost 
smatrix <- list() 
smatrix[[1]] <- seqsubm(actor.seq, method="CONSTANT") 
smatrix[[2]] <- seqsubm(activity.seq, method="CONSTANT") 
smatrix[[3]] <- seqsubm(object.seq, method="TRATE") 
smatrix[[3]] <- seqsubm(io.seq, method="TRATE")
mcdist2 <- seqdistmc(channels=list(actor.seq, activity.seq, object.seq, io.seq), 
                     method="OM", sm =smatrix, cweight=c(2,1,1)) 

