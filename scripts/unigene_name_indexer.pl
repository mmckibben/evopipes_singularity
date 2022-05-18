#!/usr/bin/perl

#This script opens up a fasta format unigene file, strips the headers and prints them back out with the number of their position beside them.  This is so we can reconcile this number with the sequence numbers used in my pipeline and its derivatives.

$NAME = "$ARGV[0]";	

open NAME or die "No file $NAME";

while (<NAME>){
	chomp $_;
	push (@names, $_);	#Push the fasta file into an array by line
}
close NAME;

@header = grep (/>/, @names); 	#create an array that only contains the headers


open (OUTFILE, ">indices.$NAME");
	$count = 0;
foreach $elem (@header){
	$count ++;
	print OUTFILE $count, "\t", $elem, "\n";
	
}

	close OUTFILE;
