#!/bin/sh 

##bcffile is the zipped VCF file which will be subset (MUST BE CHANGED)
bcffile="fullfiles.vcf.gz"

##SNPlist is the list of SNPs to be viewed (MUST BE CHANGED)
SNPlist="SNPlist.txt"

##default file names for output (OPTIONAL)
subsetbcffile="subsetbcffile.vcf.gz"
plinkout="queriedsubset"

##default file name for frequency file
freqfilename="allelefrequencies"

##default file name for population locations
poplocations="populationlocations.txt"

##subset bcf file
/Volumes/BossDaddy/1kGenomesPipeline/bcftools/bcftools view $bcffile -R $SNPlist -o $subsetbcffile

##make subset file into plink format
/usr/local/bin/plink --vcf  $subsetbcffile --make-bed --out $plinkout

##launch R
Rscript rcommandsforFamAssignment.R $plinkout

##rename files using move command for frequency analysis
mv $plinkout.bed $plinkout"_reformatted.bed"
mv $plinkout.bim $plinkout"_reformatted.bim"

##run frequency analysis
/usr/local/bin/plink --freq --family --bfile $plinkout"_reformatted" --out $freqfilename

##create map
Rscript rcommandsForGeneratingMap.R $poplocations $SNPlist $freqfilename