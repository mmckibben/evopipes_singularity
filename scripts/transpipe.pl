#!/usr/bin/perl

#################
# Barker lab, University of Arizona
# September 2020
#
# To run Transpipe: put the datafile(s) to run, a text file with a list of those filenames, and a protein file for translations wherever you want on your server. 
# To execute the pipeline, enter the command: perl transpipe.pl <names_file> <protein_file> <CPU_number>
#
#################

use warnings;

$NAME = "$ARGV[0]";
$PROT = "$ARGV[1]";
$CPU = "$ARGV[2]";
open NAME or die "No file $NAME\n";

system ("makeblastdb -in $PROT -dbtype prot");

LOOP1: while (<NAME>) {
        chomp $_;
        $taxon = $_;
        open PIPE, "uptime |";
        my $line = <PIPE>;
        close PIPE;
        $line =~ s/\s//g;
        my @lineArr =  split /:/, $line;
        my $times = $lineArr[@lineArr-1];
        my @timeArr = split /,/, $times;
        my $load = $timeArr[0] + $CPU;
	print $load," is the current load plus new CPU request\n\n";
       
	if($load < 48) {
		print "Starting pipeline for $taxon!\n\n";
		
		#Put all of your pipeline code in here
		system ("mkdir Translated/"); # make a new folder called Translated
		system ("mkdir Translated/$taxon"); # inside that folder, make separate folders for each taxon
		system ("mkdir Translated/$taxon/Output"); # makes Data folder inside taxon folder
		system ("cp $taxon Translated/$taxon"); # now all of the analyses will run inside a separate folder for each taxon
		system ("cd Translated/$taxon/; unigene_name_indexer.pl $taxon");
		system ("mv Translated/$taxon/indices* Translated/$taxon/Output/");


		#Clean sequence names, remove ones < 300bp, make blast database, dc-mega against itself
		print "running clcleaner\n\n";
		system ("cd Translated/$taxon/; clcleaner.pl $taxon"); # output is: no.cl.$NAME
		system ("cd Translated/$taxon/; min_fasta_length.pl no_cl.$taxon 300"); # output is: no_cl.$taxon.minlength$number.  Keeps only sequences longer than 300bp. 

		print "\n\nBlasting against Proteins\n\n";
		system ("cd Translated/$taxon/; blastx -num_threads $CPU -evalue 0.01 -max_target_seqs 50 -db /home/$PROT -query no_cl.$taxon.minlength300 -out out.blastx_$taxon"); # blasts your sequences against the user supplied protein sequences

		#Parse duplicates (keep best hits), clean parsed file, keep unique sequences, remove duplicates from list
		system ("cd Translated/$taxon/; blastxparser.pl out.blastx_$taxon"); # output is blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; delete_extra_infoblastx.pl blastxparsed.out.blastx_$taxon"); #output is clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; unique_hits_by_column.pl clean.blastxparsed.out.blastx_$taxon"); #output is unique_col0.clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; tabs.pl unique_col0.clean.blastxparsed.out.blastx_$taxon"); #output is tab.unique_col0.clean.blastxparsed.out.blastx_$taxon

        #Make DNA and protein ID lists, then fasta files for DNA and protein sequences, for all genes, in the same order
        print "\n\n\tMaking DNA and protein ID lists\n\n";
		system ("cd Translated/$taxon/; delete_extra_infogenewise.pl unique_col0.clean.blastxparsed.out.blastx_$taxon"); #output is clean.unique_col0.clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; dna_id_list.pl clean.unique_col0.clean.blastxparsed.out.blastx_$taxon"); #output is dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; prot_id_list.pl clean.unique_col0.clean.blastxparsed.out.blastx_$taxon"); #output is prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; dna_fasta.pl dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon no_cl.$taxon.minlength300"); #output is dna_fasta.dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon
		system ("cd Translated/$taxon/; prot_fasta2.pl prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon /home/$PROT"); #output is prot_fasta.prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon

        #Make list of gene names
        print "\n\n\tMaking list of gene names\n";
		system ("cd Translated/$taxon/; namelist.pl unique_col0.clean.blastxparsed.out.blastx_$taxon"); #output is dna_names

		#Genewise - get DNA and protein sequences for predicted proteins
        print "\n\n\tRunning Genewise\n\n";
        print "\n\n\t\tNOTE!!! YOU WILL ALWAYS GET A \"FATAL ERROR\" ON THE FIRST ONE HERE!!\n\n";
		system ("cd Translated/$taxon/; iterativegenewise.pl prot_fasta.prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon dna_fasta.dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$taxon");
		system ("cp Translated/$taxon/genewise_dnas.fasta Translated/$taxon/Output/$taxon.fna");
		system ("cp Translated/$taxon/genewise_prots.fasta Translated/$taxon/Output/$taxon.faa");
	#	system ("cp Translated/$taxon/genewise_dnas.fasta Translated/$taxon/Data/$taxon.fna");
	#	system ("cp Translated/$taxon/genewise_prots.fasta Translated/$taxon/Data/$taxon.faa");

		print "\n\n\t\tIf there is only one error above this point, you're done now!\n\n\n\n";

		# REMOVE INTERMEDIATE FILES
		system ("rm Translated/$taxon/dna_names");
		system ("rm Translated/$taxon/dirtycontig");
		system ("cd Translated/$taxon/; echo *.fasta | xargs rm");
		system ("rm Translated/$taxon/genewiseout");
		system ("rm Translated/$taxon/nostopcontig");
		system ("rm Translated/$taxon/nucseq");
		system ("rm Translated/$taxon/protseq");
		system ("rm Translated/$taxon/*.blastx_$taxon");
		system ("rm Translated/$taxon/no_cl.*");
	
	}
	
	else{
		sleep(60);
		redo LOOP1;
		
	}
}

