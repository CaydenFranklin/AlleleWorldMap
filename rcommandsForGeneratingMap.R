##uses ggplot2 and scatterpie libraries
library(ggplot2)
library(scatterpie)
library(dplyr)

wd<-"/Volumes/BossDaddy/1kGenomesPipeline/"
setwd(wd)
args = commandArgs(trailingOnly = TRUE)
poplocations<- paste(args[1])
snpNames<- paste(args[2])
mAlelleFrequencies<-paste(args[3],".frq.strat", sep = "")
popLocationsTable <- read.table(poplocations, stringsAsFactors = FALSE)

##V3 will have the SNP id
snpListTable <- read.table(snpNames, stringsAsFactors = FALSE)
mAlelleFrequenciesTable <- read.table(mAlelleFrequencies, header = TRUE, stringsAsFactors = FALSE)

fulldf <- merge(mAlelleFrequenciesTable, popLocationsTable, by.x = "CLST", by.y ="V1", all.x = TRUE)

##Grabs collumns for: SNP ID, A1, A2, Minor Allele Frequency (MAF), lat, long
dfforplotting <- fulldf[,c(3,4,5,6,9,10)]


##iterates over each SNP in the list 
for(var in snpListTable$V3)
	{
		#only select rows with the given SNP
		editeddf <- dfforplotting[ dfforplotting$SNP == var, ]

		#rename coordinate collumns
		names(editeddf)[names(editeddf) == "V2"] <- "lat"
		names(editeddf)[names(editeddf) == "V3"] <- "long"
		names(editeddf)[names(editeddf) == "MAF"] <- "Minor_Allele_Frequency"

		##not neccesarily minor/major, but plink refers to the first allele as minor for the calculation of the MAF stat
		minorAlleleBase <- editeddf[1,2]
		majorAlleleBase <- editeddf[1,3]

		##calculate major allele frequency
		editeddf$Major_Allele_Frequency <- 1-editeddf$Minor_Allele_Frequency
		pdf(paste(var, "alleleFrequencyplot.pdf", sep = ""))

		##removes Antartica, to save vertical space
		world <- map_data("world") %>% filter(region != "Antarctica") 

		p <- ggplot(world, aes(long, lat), color = "lightblue") + geom_map(map=world, aes(map_id=region), fill="#f7d7a3", color="#f7d7a3") + coord_quickmap()

		p <- p + theme( panel.background = element_rect(fill = "lightblue", colour = "lightblue", size = 0.5, linetype = "solid"),
			panel.grid.major = element_blank(), panel.grid.minor = element_blank())

		##center title 
		p <- p + ggtitle(paste(var, " frequency", sep = "")) + theme(plot.title = element_text(hjust = 0.5))

		collumn <- c(paste(majorAlleleBase), paste(minorAlleleBase))
		##plot pie charts
		print(p + geom_scatterpie(aes(x=long, y=lat, group=1, r=5), data=editeddf, cols=c("Minor_Allele_Frequency","Major_Allele_Frequency"), alpha=.8)+
        scale_fill_manual(values=c("lightskyblue1","palevioletred2")) + scale_fill_discrete(name = "Frequency", labels = collumn))		
        dev.off() 

	}

