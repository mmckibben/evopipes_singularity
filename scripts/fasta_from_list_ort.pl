#!/usr/bin/perl

#Takes a list of names and searches against a fasta file and produces a filtered fasta file containing only the sequences in the list.
$ID = shift @ARGV;
@taxa = @ARGV;
$num_taxa = scalar @taxa;
@ids = ();
@fasta = ();
@fasta2 = ();
@seqs = ();


open ID or die "No file $ID";		#READ ID into an array
while (<ID>){
	push (@ids, $_);
}
close ID;


#then do the fasta loop with undefine
#then a foreach loop with id array grep against @fasta

foreach (@taxa){
	$FASTA = "no_cl.$_\.unigenes";
	open FASTA or die "No file $FASTA";

	for ($junk = 0; $junk <1;  $junk++){
		undef $/;
		while (<FASTA>) {
			$_ =~ s/>/__>/g;

			@fasta2 = split /__/, $_;
		}	
	}
	close FASTA;
	foreach $seq (@fasta2) {
		$seq =~ s/\.//g;
		push @fasta, $seq;
	}
}

open OUTFILE, ">unique_seqs.$ID";
foreach $seqid (@ids){
	$seqid =~ s/\.//g;
	@seqs = grep (/$seqid/, @fasta);	
	
	print OUTFILE $seqs[0];
	
	
}

close OUTFILE;



