### Title: 05_Phage_Annotation.sh ###
### Author: Ema H Graham ###
### For Questions Email: ema.graham@huskers.unl.edu ###

############################################
## -------------------------------------- ##
## ------------- Description ------------ ##
## -------------------------------------- ##
############################################

#Input Notes:
#This is the fifth step of this pipeline is designed to be used after completing step 3. Identification of Phage Contigs
#This pipeline should begin using the fasta files META_unmapped_1000_contigs.phages_combined.fna generated using 03_Identify_Phage.sh
#The meta-assembly was used (i.e., META_unmapped_1000_contigs.phages_combined.fna) for this initial assessment of taxonomy.

#Output Notes:
#This pipeline will annotate and taxonomically classify bacteriophage from your viral genome assembles 
#The next step in this pipeline is the next step in pipeline is 6. Phage_Annotation (04_Phage_Mapping.sh)

#General Notes:
#This pipeline is designed to be run using the Holland Computing Center at the University of Nebraska. Some tool commands may differ depending on installation of the tool. Please refer to the listed Githubs for each tool used as mentioned in script for further information if issues arise 
#Some file locations may differ from yours so this needs to be changed accordingly. This script is designed to be run all in one folder
#This script is designed to be used post the first and second steps of the pipeline, however any contig assembly fasta file can be used with this script

############################################
## -------------------------------------- ##
## --------------- Kraken2 -------------- ##
## -------------------------------------- ##
############################################

#Kraken2 v.2.0.8-beta was used to annotate the checkv identified viral contigs in the META_unmapped_1000_contigs.phages_combined.fna file
#Kraken2 can be found at: http://ccb.jhu.edu/software/kraken2/index.shtml

mkdir KRAKEN/
kraken2-build --download-taxonomy --db KRAKEN/
kraken2-build --download-library viral --db KRAKEN/
kraken2-build --build --db KRAKEN/
kraken2 --use-names  --db META_unmapped_1000_contigs.phages_combined.fna > kraken_output.txt

#Will result in a kraken_output.txt file that will be used in conjunction  with the output files of kaiju, demovir, and independent blast searches

############################################
## -------------------------------------- ##
## ---------------- Kaiju --------------- ##
## -------------------------------------- ##
############################################

#Kaiju v.1.7 was used to annotate the Checkv identified viral contigs in the META_unmapped_1000_contigs.phages_combined.fna file
#Kaiju can be found at: https://kaiju.binf.ku.dk

kaiju -t $NODES -f $KAIJU_DB_VIRUSES -i META_unmapped_1000_contigs.phages_combined.fna -x -m 11 -a greedy -e 5 -E 0.001 -v -o kaiju_virus.out

kaiju-addTaxonNames -t $NODES -n $NAMES -v  -r superkingdom,phylum,class,order,family,genus,species -i kaiju_virus.out -o kaiju_virus_names.tsv

kaiju -t $NODES -f $KAIJU_DB -i META_unmapped_1000_contigs.phages_combined.fna -x -m 11 -a greedy -e 5  -E 0.001 -v -o kaiju_DB.out

kaiju-addTaxonNames -t $NODES -n $NAMES -v -r superkingdom,phylum,class,order,family,genus,species -i kaiju_DB.out -o kaiju_DB_names.tsv

#Will result in both kaiju_virus_names.tsv and kaiju_DB_names.tsv files that will be used in conjunction  with the output files of demovir, kraken2, and independent blast searches


############################################
## -------------------------------------- ##
## --------------- Demovir -------------- ##
## -------------------------------------- ##
############################################

#Demovir was used to annotate the Checkv identified viral contigs in the META_unmapped_1000_contigs.phages_combined.fna file
#Demovir can be found at: https://github.com/feargalr/Demovir

#For those using the HCC at UNL make sure to module load the following to use Demovir:
  #module load usearch/11.0
  #module load prodigal/2.6
  #module load ​R/3.6

mkdir Demovir
#git clone https://github.com/feargalr/Demovir.git
cd Demovir/
chmod +x *.sh
#download database from: https://figshare.com/articles/NR_Viral_TrEMBL/5822166
./format_db.sh

prodigal -a AA.fasta -i META_unmapped_1000_contigs.phages_combined.fna -p meta &> /dev/null
usearch -ublast AA.fasta -db uniprot_trembl.viral.udb -evalue 1e-5 -blast6out trembl_ublast.viral.txt -trunclabels &> /dev/null
sort -u -k1,1 trembl_ublast.viral.txt > trembl_ublast.viral.u.txt
rm AA.fasta
cut -f 1,2 trembl_ublast.viral.u.txt | sed 's/_[0-9]\+\t/\t/' | cut -f 1 | paste trembl_ublast.viral.u.txt - > trembl_ublast.viral.u.contigID.txt
rm trembl_ublast.viral.u.txt trembl_ublast.viral.txt
Rscript demovir.R
rm trembl_ublast.viral.u.contigID.txt

#Will result in a demovir_assignments.txt file that will be used in conjunction with the output files of kaiju, kraken2, and independent blast searches

############################################
## -------------------------------------- ##
## --------------- BlastN --------------- ##
## -------------------------------------- ##
############################################

#Each contig was run through Blast using the BlastN algorithm. Only hits with >10% coverage were considered true results. The top his was recorded in an excel sheet manually

#All annotation outputs were recorded in an excel file and the best annotation for each contig was determined as explained in the materials in methods. This resulted in the edited_annotation.csv file.
#In Excel for all "NA" present in annotation file, they were replaced with "Unclassified XX" where "XX" represents the highest known grouping for that contig (e.g., "Unclassified Viruses" or "Unclassified Caudovirales"). Only Family or higher taxonomic level groupings were used (i.e., Species and Genus were not retained) to reduce inaccurate viral classifications. 
