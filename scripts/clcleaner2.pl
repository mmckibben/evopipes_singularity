#!/usr/bin/perl

$NAME = "$ARGV[0]";	
$taxon = "$ARGV[1]";
open NAME or die "No file $NAME";
my @lines = ();
while (<NAME>) {
	$_ =~ s/CL/$taxon/g;
	@split= split /\s/, $_;
	push @lines, "$split[0]";
}
close NAME;
$temp = join '____', @lines;
@fasta = split /\>/, $temp;
open (OUTFILE, ">no_cl.$NAME");
open (OUTFILE2, ">names_used$taxon");
for ($i=1; $i< (scalar @fasta); $i++){
	@temp2 = split /____/, $fasta[$i];
	$name = shift @temp2;
	print OUTFILE ">$taxon$i\n";
	print OUTFILE2 "$name\t$taxon$i\n";
	foreach (@temp2){
		print OUTFILE $_;
	}
	print OUTFILE "\n";
}
close OUTFILE;
close OUTFILE2;

