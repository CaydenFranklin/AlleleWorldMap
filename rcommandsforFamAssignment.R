args = commandArgs(trailingOnly = TRUE)
wd<-"/Volumes/BossDaddy/1kGenomesPipeline/"
FAMfile<- paste(args[1],".fam", sep = "")
referenceFile<-"FAMinformation.txt"
setwd(wd)
fam.df <- read.table(FAMfile, as.is = T, header = F)
ref.df <- read.table(referenceFile, as.is = T, header = T)
final.df <- merge(fam.df, ref.df, by.x = 2, by.y = 1)
export.df <- final.df[ ,c(7,2,3,4,5,6)]
reformattedfilename <- paste(args[1], "_reformatted.fam", sep = "")
write.table(export.df,reformattedfilename,row.names = F, col.names = F,quote = F)
