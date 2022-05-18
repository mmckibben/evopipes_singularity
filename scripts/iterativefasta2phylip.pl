#!/usr/bin/perl

$INFILE = "dnapairnumber";
open INFILE or die "no file $INFILE\n";
$count = 0;
while (<INFILE>) {
	chomp $_;
	$count = $_;
}
close INFILE;
for ($i=0; $i < $count; $i++){
	system ("perl /bin/Fasta2Phylip.pl dnaaln$i.fasta dnaaln$i.phy");
}


	





