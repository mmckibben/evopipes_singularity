#!/usr/bin/perl

#################
# Barker lab, University of Arizona
# September 2020
#
# To run OrthoPipe: put the datafile(s) to run, a file with a list of their names, and a protein file for translations wherever in your folder you like.
# Each file should be named in the format "XYZ.unigenes" and the <names_file> file should contain the three letter codes for each species you want to analyze on each line.
# For example: XYZ ABC DOG  would identify reciprical best BLAST-hit orthologs for these three taxa.
# To execute the pipeline, enter at the command line prompt: perl orthopipe.pl <names_file> <protein_file> <CPU_Number>
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
        $row_of_names = $_;
        open PIPE, "uptime |";
        my $line = <PIPE>;
        close PIPE;
        $line =~ s/\s//g;
        my @lineArr =  split /:/, $line;
        my $times = $lineArr[@lineArr-1];
        my @timeArr = split /,/, $times;
        my $load = $timeArr[0] + $CPU;

		print "Starting pipeline for $row_of_names!\n\n";

		#Put all of your pipeline code in here;
	@compare = ();


	@taxa_list = ();
	@taxa = ();

# read in the list of taxa to be analyzed
	push @compare, $row_of_names; # save each comparison separately
	@temp = split / /, $_;
	foreach $tmp (@temp){
		push @taxa_list, $tmp; # make a list of all taxa
	}

# get rid of duplicates in the list of taxa
	@taxa_list = sort @taxa_list;
	$last = "";
	foreach (@taxa_list){
		if ($_ eq $last){
		next;
	}
	else {
		push @taxa, $_;
		$last = $_;
	}
}


		system ("mkdir OrthoPipe/");


@taxa = ();
foreach (@compare){

	@taxa = split / /, $_;
	$taxa_num = scalar @taxa;
	$all_taxa = join '_', @taxa;
	system ("mkdir OrthoPipe/$all_taxa");
	system ("mkdir OrthoPipe/hit_parser");
		system ("mkdir OrthoPipe/$all_taxa");
		system ("mkdir OrthoPipe/$all_taxa/Output");

foreach $taxon (@taxa){  #format databases for blast
	system ("cp $taxon.unigenes OrthoPipe/$all_taxa");

	system ("cd OrthoPipe/$all_taxa/; unigene_name_indexer.pl $taxon.unigenes");
	system ("mv OrthoPipe/$all_taxa/indices* OrthoPipe/$all_taxa/Output/");

	system ("cd OrthoPipe/$all_taxa; clcleaner2.pl $taxon.unigenes $taxon");

	system ("cd OrthoPipe/$all_taxa/; min_fasta_length.pl no_cl.$taxon.unigenes 300"); # output is: no_cl.$all_taxa.minlength$number.  Keeps only sequences longer than 300bp.
	system ("cd OrthoPipe/$all_taxa/; makeblastdb -in no_cl.$taxon.unigenes.minlength300 -dbtype nucl");
}



for ($i = 0; $i < $taxa_num; $i++) {
		for ($j = 0; $j < $taxa_num; $j++){
			if ($i == $j) {next;}
			if (-e "OrthoPipe/hit_parser/parsed.hits.$taxa[$i]vs$taxa[$j]") {
				system ("cp OrthoPipe/hit_parser/parsed.hits.$taxa[$i]vs$taxa[$j] OrthoPipe/$all_taxa/");
				next;
			}
			else { # otherwise, blast and then parse results
				system ("cd OrthoPipe/$all_taxa; blastn -task dc-megablast -template_length 16 -template_type coding_and_optimal -word_size 11 -num_threads $CPU -evalue 0.1 -perc_identity 50 -db no_cl.$taxa[$j].unigenes.minlength300 -query no_cl.$taxa[$i].unigenes.minlength300 -out out.allvsall.$taxa[$i]vs$taxa[$j]");
				system ("cd OrthoPipe/$all_taxa; blasthitparse2.pl out.allvsall.$taxa[$i]vs$taxa[$j] $taxa[$i]vs$taxa[$j]");

			}
		}
	}
system ("cd OrthoPipe/$all_taxa; multiple_orthologs_stringent.pl @taxa > orthologs.$all_taxa");
system ("cd OrthoPipe/$all_taxa; list_ort.pl orthologs.$all_taxa $taxa_num");
system ("cd OrthoPipe/$all_taxa; fasta_from_list_ort.pl list.orthologs.$all_taxa @taxa");
system ("cd OrthoPipe/$all_taxa; makeblastdb -in unique_seqs.list.orthologs.$all_taxa -dbtype nucl");
system ("cd OrthoPipe/$all_taxa; blastx -num_threads $CPU -evalue .1 -max_target_seqs 50 -db $PROT -query unique_seqs.list.orthologs.$all_taxa -out out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; blastxparser.pl out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; delete_extra_infoblastx.pl blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; unique_hits_by_column.pl clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; tabs.pl unique_col0.clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; delete_extra_infogenewise.pl unique_col0.clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; dna_id_list.pl clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; prot_id_list.pl clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; dna_fasta_ort.pl dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa @taxa");
system ("cd OrthoPipe/$all_taxa; prot_fasta2.pl prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa $PROT");
system ("cd OrthoPipe/$all_taxa; namelist.pl unique_col0.clean.blastxparsed.out.blastx_$all_taxa");
system ("cd OrthoPipe/$all_taxa; iterativegenewise_orthologs.pl prot_fasta.prot_ids1.clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa dna_fasta.dna_ids0.clean.unique_col0.clean.blastxparsed.out.blastx_$all_taxa $all_taxa");
system ("cd OrthoPipe/$all_taxa; iterativemuscle2.pl orthologs.$all_taxa genewise_prots$all_taxa.fasta");
system ("cd OrthoPipe/$all_taxa; iterativerevtrans2.pl orthologs.$all_taxa genewise_dnas$all_taxa.fasta");
system ("cd OrthoPipe/$all_taxa; iterativefasta2phylip.pl");
system ("cd OrthoPipe/$all_taxa; iterativepaml.pl");
system ("cd OrthoPipe/$all_taxa; find *.dS -print | xargs cat > ksvaluescodeml$all_taxa");
system ("cd OrthoPipe/$all_taxa; find *.dN -print | xargs cat > kavaluescodeml$all_taxa");
system ("cd OrthoPipe/$all_taxa; blastn -task dc-megablast -num_threads $CPU -evalue .01 -db /bin/ath.fasta -query unique_seqs.list.orthologs.$all_taxa -out out.ath_vs_$all_taxa ");
system ("cd OrthoPipe/$all_taxa; blastxparser.pl out.ath_vs_$all_taxa ");
system ("cd OrthoPipe/$all_taxa; delete_extra_infoblastx.pl blastxparsed.out.ath_vs_$all_taxa ");
system ("cd OrthoPipe/$all_taxa; tabs.pl clean.blastxparsed.out.ath_vs_$all_taxa");
system ("cd OrthoPipe/$all_taxa; paml_output_reformat_no_lrt.pl kavaluescodeml$all_taxa ksvaluescodeml$all_taxa tab.unique_col0.clean.blastxparsed.out.blastx_$all_taxa tab.clean.blastxparsed.out.ath_vs_$all_taxa $all_taxa @taxa");
system ("cp OrthoPipe/$all_taxa/codeml_output$all_taxa OrthoPipe/$all_taxa/Output/");


		#Save all data and programs in a tar file, if you really want to...
		#system ("tar -czvf $all_taxa.tgz Programs/");
		#system ("mv $all_taxa.tgz Data/$all_taxa");

		#Remove all intermediate files generated
		print "\n\tDeleting intermediate files!\n\n";
		system ("rm OrthoPipe/$all_taxa/dna_names");
		system ("cd OrthoPipe/$all_taxa/; echo *.aln | xargs rm");
		system ("rm OrthoPipe/$all_taxa/DNA*");
		system ("cd OrthoPipe/$all_taxa/; echo pamlout* | xargs rm");
		system ("cd OrthoPipe/$all_taxa/; echo *.t | xargs rm");
		system ("cd OrthoPipe/$all_taxa/; echo *.dN | xargs rm");
		system ("cd OrthoPipe/$all_taxa/; echo *.dS | xargs rm");
		system ("cd OrthoPipe/$all_taxa/; echo *.phy | xargs rm");
		system ("rm OrthoPipe/$all_taxa/ksvalues");
		system ("rm OrthoPipe/$all_taxa/dnapairnumber");
		system ("rm OrthoPipe/$all_taxa/no_zero_ks");
		system ("rm OrthoPipe/$all_taxa/final_ks_values");
		system ("cd OrthoPipe/$all_taxa/; echo *.fasta | xargs rm");
		system ("rm OrthoPipe/$all_taxa/dirtycontig");
		system ("cd OrthoPipe/$all_taxa/; echo *.fa | xargs rm");
		system ("rm OrthoPipe/$all_taxa/genewiseout");
		system ("rm OrthoPipe/$all_taxa/nostopcontig");
		system ("rm OrthoPipe/$all_taxa/nucseq");
		system ("rm OrthoPipe/$all_taxa/protseq");
	#	system ("echo *.unigenes | xargs rm");
		system ("rm OrthoPipe/$all_taxa/*.allvsall.$all_taxa");
		system ("rm OrthoPipe/$all_taxa/unique_seqs*");
		system ("rm OrthoPipe/$all_taxa/no_cl.*");
		system ("rm OrthoPipe/$all_taxa/out.ath_*");
		system ("rm OrthoPipe/$all_taxa/*.blastx_$all_taxa");
		system ("rm OrthoPipe/$all_taxa/kavalues");
		system ("rm OrthoPipe/$all_taxa/out.*");
		system ("rm OrthoPipe/$all_taxa/clean.*");
		system ("rm OrthoPipe/$all_taxa/parsed.out.*");
		system ("rm OrthoPipe/$all_taxa/tab.unique*");
		system ("rm OrthoPipe/$all_taxa/unique_col0*");
		system ("rm OrthoPipe/$all_taxa/*fasta.clean*");
		system ("rm OrthoPipe/$all_taxa/*.seqs");
		system ("rm OrthoPipe/$all_taxa/annotations");
		system ("rm OrthoPipe/$all_taxa/ath_annotations");
		system ("rm OrthoPipe/$all_taxa/codeml.ctl");
		system ("rm OrthoPipe/$all_taxa/rst*");
		system ("rm OrthoPipe/$all_taxa/rub");
	}

}
