#!/usr/bin/perl

$CONTROL = "/bin/mastercodeml_lrt1.ctl";
$CONTROL2 = "/bin/mastercodeml_lrt2.ctl";
$INFILE = "dnapairnumber";
$PAMLOUT = "pamlout";
$TREE = "/bin/tree_master";
@log_likelihoods = ();
@ml_trees = ();
@taxa = @ARGV;

#get the count for the number of alignments
open INFILE or die "no file $INFILE\n";
$count = 0;
while (<INFILE>) {
	chomp $_;
	$count = $_;
}
close INFILE;

open OUTFILE3, ">lrt.txt";
for ($i=0; $i < $count; $i++){
	$ALN = "dnaaln$i.phy";
	open ALN or die "no file $ALN\n";
	@aln = ();
	while (<ALN>){
		$_ =~ s/\s//g;
		chomp $_;
		push @aln, $_;
	}
	close ALN;

	open TREE;
	open OUTFILE2, ">tree";
	while (<TREE>){
		print $_;
		foreach $taxon (@taxa) {
			@temp = grep /$taxon/, @aln;
				
			$_ =~ s/$taxon/$temp[0]/;
		}
		print OUTFILE2 $_;
		print $_;
	}

	@ll = ();
	@temp = ();
	@temp2 = ();
	@temp3 = ();
	@temp4 = ();
	@names = ();
	$names2;
	open CONTROL or die "no control file $CONTROL\n";
	open OUTFILE, ">codeml.ctl";
	while (<CONTROL>) {
		$_ =~ s/QQQQQQQ/dnaaln$i.phy/;
		print OUTFILE $_;
		}
	close OUTFILE;
	close CONTROL;
		
	system ("codeml codeml.ctl");
	system ("cp pamlout pamlout_lrt1_$i");

	open PAMLOUT or die "no file PAMLOUT\n";
	while (<PAMLOUT>){
		push @temp, $_;
	}
	
	@temp2names = grep /\#/, @temp;
	@temp2 = grep /lnL/, @temp;
	@temp3 = split /\s/, $temp2[0];
	@temp4 = grep /\-/, @temp3;
	push @ll,  $temp4[0];

	@temp = ();
	@temp2 = ();
	open CONTROL2 or die "no control file $CONTROL2\n";
	open OUTFILE, ">codeml.ctl";

	while (<CONTROL2>) {
		$_ =~ s/QQQQQQQ/dnaaln$i.phy/;
		print OUTFILE $_;
		}
	close OUTFILE;
	close CONTROL2;
		
	system ("codeml codeml.ctl");
	system ("cp pamlout pamlout_lrt2_$i");

	open PAMLOUT or die "no file PAMLOUT\n";
	while (<PAMLOUT>){
		push @temp, $_;
	}
	
	@temp2 = grep /lnL/, @temp;
	@temp3 = split /\s/, $temp2[0];
	@temp4 = grep /\-/, @temp3;
	push @ll,  $temp4[0];
	$lrt = 2 * ($ll[1] - $ll[0]);
	pop @temp2names;
	foreach (@temp2names){
		$_ =~ s/\#\d*//g;
		$_ =~ s/\s//g;
		$_ =~ s/\://g;
		chomp $_;
		push @names, $_;
	}
	$ll1 = $ll[0];
	$ll2 = $ll[1];
	$names2 = join "\t", @names;
	print OUTFILE3 "$i\t$names2\t$ll1\t$ll2\t$lrt\n";
	print "\nanother line of output:\n$i\t$names2\t$ll1\t$ll2\t$lrtn";
}

close OUTFILE;
exit;
	
