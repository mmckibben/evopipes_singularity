#!/usr/bin/perl

# Creates a single list of sequence names from the orthologs file 

$NAME = "$ARGV[0]";	
$num_taxa = $ARGV[1];
open NAME or die "No file $NAME";
open (OUTFILE, ">list.$NAME");
while (<NAME>) {
	chomp $_;
	@cols = split /=/, $_; 
	for ($i = 0; $i < $num_taxa; $i++){
		print OUTFILE "$cols[$i]\n";
	}
}
close NAME;

close OUTFILE; 
