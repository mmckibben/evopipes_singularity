#!/usr/bin/perl

$column = 0;
$NAME = "$ARGV[0]";
open (OUTFILE, ">dna_ids$column.$NAME");
open NAME or die "Cant' find file $NAME";
	@unique = ();
	%seen = ();
	while (<NAME>){
		@cols = split /=/, $_;
		$hit = @cols[$column];
		#push(@unique,$hit);

	print OUTFILE "$hit\n";

	}
	close NAME;
	close OUTFILE;
	


exit;

