#!/usr/bin/perl

$column = 1;
$NAME = "$ARGV[0]";
open NAME or die "Cant' find file $NAME";
	
	@unique = ();
	%seen = ();
	open (OUTFILE, ">prot_ids$column.$NAME");
	while (<NAME>){
		$_ =~ s/ //g;
		$_ =~ s/\|//g;
		$_ =~ s/\.\w+//g;
		$_ =~ s/gi//g;
		$_ =~ s/gb\w+//g;
		$_ =~ s/dbj\w+//g;
		$_ =~ s/emb\w+//g;
		$_ =~ s/pir\w+//g;
		$_ =~ s/ref\w+//g;
		$_ =~ s/sp\w+//g;
		$_ =~ s/pdb\w+//g;
		$_ =~ s/prf\w+//g;
		@cols = split /=/, $_;
		
		$hit = @cols[$column];
		#push(@unique,$hit);

	print OUTFILE "$hit\n";

	}
	close NAME;
	close OUTFILE;	


exit;

