### Title: 03_Identify_Phage ###
### Author: Ema H Graham ###
### For Questions Email: ema.graham@huskers.unl.edu ###

############################################
## -------------------------------------- ##
## ------------- Description ------------ ##
## -------------------------------------- ##
############################################

#Input Notes:
#This is the third step of this pipeline is designed to be used after completing 02_Virome_Assembly.sh
#This pipeline should begin using the fasta files META_unmapped_1000_contigs.fa and SAMPLE_unmapped_1000_contigs.fa generated using 02_Virome_Assembly.sh

#Output Notes:
#This pipeline will identify bacteriophage from your viral genome assembles 
#The next step in this pipeline is the next step in pipeline is 4. Phage_Annotation (04_AMG_Bar_Graph.sh)

#General Notes:
#This pipeline is designed to be run using the Holland Computing Center at the University of Nebraska. Some tool commands may differ depending on installation of the tool. Please refer to the listed Githubs for each tool used as mentioned in script for further information if issues arise 
#Some file locations may differ from yours so this needs to be changed accordingly. This script is designed to be run all in one folder
#This script is designed to be used post the first and second steps of the pipeline, however any contig assembly fasta file can be used with this script

############################################
## -------------------------------------- ##
## ----------- Combine Contigs ---------- ##
## -------------------------------------- ##
############################################

#the meta-assembly contigs and the within sample-assembly were combined together into one file

cat META_unmapped_1000_contigs.fa SAMPLE_unmapped_1000_contigs.fa > ALL_unmapped_1000_contigs.fa

############################################
## -------------------------------------- ##
## ------- Identify Phage Genomes ------- ##
## -------------------------------------- ##
############################################

#Phage identification was performed on the fasta file containing all contigs using the bacteriophage identification tool VIBRANT
#VIBRANT is avalible here: https://github.com/AnantharamanLab/VIBRANT

#This was repeated for the meta-assembly and the witin-sample assemblies to assess differences for the assembly methods
mkdir VIBRANT_OUTPUT_CONTIGS
VIBRANT_run.py -virome -i ALL_unmapped_1000_contigs.fa 
cp VIBRANT_ALL_unmapped_1000_contigs/VIBRANT_phages_ALL_unmapped_1000_contigs/ALL_unmapped_1000_contigs.phages_combined* ./VIBRANT_OUTPUT_CONTIGS/
VIBRANT_run.py -virome -i META_unmapped_1000_contigs.fa
cp VIBRANT_META_unmapped_1000_contigs/VIBRANT_phages_META_unmapped_1000_contigs/META_unmapped_1000_contigs.phages_combined* ./VIBRANT_OUTPUT_CONTIGS/
VIBRANT_run.py -virome -i SAMPLE_unmapped_1000_contigs.fa
cp VIBRANT_SAMPLE_unmapped_1000_contigs/VIBRANT_phages_SAMPLE_unmapped_1000_contigs/SAMPLE_unmapped_1000_contigs.phages_combined* ./VIBRANT_OUTPUT_CONTIGS/

#Figure 1A was PCoA Plot produced via VIBRANT and is a standard output produced by VIBRANT
#Figures 3B & 3C AMG plots were roduced via VIBRANT and is a standard output produced by VIBRANT 
