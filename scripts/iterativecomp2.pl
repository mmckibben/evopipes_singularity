#!/usr/bin/perl

$taxon1 = $ARGV[0];
$taxon2 = $ARGV[1];
$taxonOut = $ARGV[2];
$all_taxa = $ARGV[3];

print "\n\n\t$taxon1\n";
print "\n\n\t$taxon2\n";
print "\n\n\t$taxonOut\n";
print "\n\n\t$all_taxa\n";

$taxonnames = join (".", $taxon1, $taxon2, $taxonOut); 

print "\n\n\t$taxonnames\n\n";

opendir (DIR, "protalns");
@FILES = readdir (DIR);
closedir (DIR);

#shift(@FILES);
#shift(@FILES);

print "protein alignment 0 is: $FILES[0]\n";
print "protein alignment 1 is: $FILES[1]\n";
print "protein alignment 2 is: $FILES[2]\n";
print "protein alignment 3 is: $FILES[3]\n";
print "protein alignment 4 is: $FILES[4]\n";
print "protein alignment 5 is: $FILES[5]\n";
print "protein alignment 6 is: $FILES[6]\n";
print "protein alignment 7 is: $FILES[7]\n";


open OUT, ">$all_taxa.comp_info.txt";
print OUT "Outgroup\tSeqOne\tSeqTwo\tTotal\tGaps\tUngap\tEqual\tSame\tDiff\tComp1\tComp2\tTotComp\t%Same\t%Diff\t%Comp1\t%Comp2\t%TotComp\n";

foreach $file (@FILES) {
	unless ($file eq "." || $file eq "..") { 
		system ("test_comp_mut2.pl $file $taxonnames $all_taxa");
	}
}