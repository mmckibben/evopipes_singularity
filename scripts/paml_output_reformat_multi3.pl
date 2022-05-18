#!/usr/bin/perl

# This program puts together a single tab delimited file with ka, ks, ka/ks, nj trees and annotation
# note: the njtrees are unrooted.  Thus, (A,(B,C),D) is the same tree as (A,(C,B),D) and (B,(A,D),C) and (A,(B,C),D) and ((A,D),(C,B)) 

$INFILE1 = shift @ARGV; # ka file
$INFILE2 = shift @ARGV; # ks file
$INFILE3 = shift @ARGV; # annotation file
$INFILE4 = shift @ARGV; # arabidopsis annotation file
$INFILE5 = "lrt.txt"; #lrt file
$all_taxa = shift @ARGV;
@taxa = @ARGV; # taxa
$taxa_num = scalar @ARGV; # number of taxa


my @ka_file = ();
my @ks_file = ();
my @ka_comp = ();
my @ks_comp = ();

my @values =();

my @query = ();

my @hit = ();
my @annotation = ();
my @ath_annotation = ();
my @GO = ();

my @output = ();

my @final = ();

my $kaks = ();
my @lrt = ();



# read in ka and ks values

open INFILE1 or die "no file $INFILE1\n";

while (<INFILE1>) {
	chomp $_;

	push @ka_file, $_;
}

close INFILE1;


open INFILE2 or die "no file $INFILE2\n";

while (<INFILE2>) {
	chomp $_;

	push @ks_file, $_;
}

close INFILE2;

$temp1 = join '____', @ka_file;
@ka_comp = split /    \d+____/, $temp1;


$temp2 = join '____', @ks_file;
@ks_comp = split /    \d+____/, $temp2;

open INFILE3 or die "no file $INFILE3\n";

while (<INFILE3>){

	push @annotation, $_;

}
close INFILE3;
open INFILE4 or die "no file $INFILE4\n";

while (<INFILE4>){

	push @ath_annotation, $_;

}
close INFILE4;
open INFILE5 or die "no file $INFILE5\n";

while (<INFILE5>){

	push @lrt, $_;

}
close INFILE5;
@taxa = sort @taxa;

open OUTFILE, ">codeml_output$all_taxa";

for ($t = 1; $t < $taxa_num; $t++){
	for ($u = 0; $u < $t; $u++){
		print OUTFILE "Query$taxa[($u)]\tHit$taxa[$t]\tKa$taxa[($u)]vs$taxa[$t]\tKs$taxa[($u)]vs$taxa[$t]\tKa/Ks$taxa[($u)]vs$taxa[$t]\t"
	}
}
print OUTFILE "L1\tL2\tLRT\tNJtree\tAth annotation\tAnnotated EST\tViridiplantae annotation GI\tDescription\n";
for ($i = 0; $i < (scalar (@ka_comp)); $i++){
	$num = 0;
	@pairs = ();
	@names = ();
	@taxon = ();
	$proten = '';
	$ath_hit = '';
	@GO_hits = ();
	$lr1 = '';
	$lr2 = '';
	$lrtest = '';
	%out = ();
	$tree = "";
	@fam_ka = split /____/, $ka_comp[$i];
	@fam_ks = split /____/, $ks_comp[$i];
	unless ((scalar @fam_ka)== ($taxa_num + 1)){next;} # only if all orthologs present
	
	for ($j = 0; $j < $taxa_num; $j++){
		$name = "";

		@tabs_ka = ();
		@tabs_ks = ();
		$taxon_name = substr $fam_ka[$j], 0, 3;

		@tabs_ka = split /\s+/, $fam_ka[$j];
		@tabs_ks = split /\s+/, $fam_ks[$j];
		$name = $tabs_ka[0];
		$names[$j] =  $name;
		$taxon[$j] = $taxon_name;
		unless ($j == 0){
				for ($k = 1; $k <= $j; $k++){
				@prots = ();
				@ath = ();
				@temp = ();
				$query = $name;
				$hit = $names[($k-1)];
				$ka = $tabs_ka[$k];
				$ks = $tabs_ks[$k];
				if ($ks == 0) {

					$kaks = NA;

				}
				else{

					$kaks = ($ka/$ks);

				}

				push @pairs, "$taxon_name\t$taxon[$k-1]\t$ks";

				@prots = grep /$query/, @annotation;
				$out{"$taxon_name$taxon[$k-1]"} = "$query\t$hit\t$ka\t$ks\t$kaks\t";
				$out{"$taxon[$k-1]$taxon_name"} = "$hit\t$query\t$ka\t$ks\t$kaks\t";
				chomp $prots[0];
				$protein = "$prots[0]";
#GO annotation
				@ath = grep /$query\t/, @ath_annotation;
				@tabs = split /\t/, $ath[0];
				if ($ath_hit eq ''){
					$ath_hit = $tabs[1];
					$ath_hit =~ s/\>//g;
				}
				if ($lrtest eq ''){
					@temp = grep /$query\t/, @lrt;
					$lrt_hit = $temp[0];
					chomp $lrt_hit;
					@tabs3 = split /\t/, $lrt_hit;
					$lrtest = pop @tabs3;
					$lr2 = pop @tabs3;
					$lr1 = pop @tabs3;
				}
			}
		}
	}
	for ($v = 1; $v < $taxa_num; $v++){
		for ($w = 0; $w < $v; $w++){
			print OUTFILE $out{"$taxa[$w]$taxa[$v]"};
		}
	} 
	$tree = njtree (@pairs);
	if ($ath_hit eq ''){
		$ath_hit = "none";
	}
	print OUTFILE "$lr1\t$lr2\t$lrtest\t$tree\t$ath_hit\t$protein\n";
}
close OUTFILE;




#### subroutines
sub njtree {
	my (@ks_values) = @_;
	$query = "";
	$hit = "";
	# pull off the node with the lowest ks, until no nodes are left
	while (scalar @ks_values){
		my @ks_values_new = ();
		my $lowest_ks = 1000;
		my $lowest_line = "";
		my $lowest_line_no=0;
		$query = "";
		$hit = "";
		my @query_match =();
		my @hit_match = ();
		#find lowest ks value
		for ($j=0; $j< scalar @ks_values; $j++){
			chomp $ks_values;
			my @tabs3 = split /\t/, $ks_values[$j];
			my $ks = $tabs3[2];
			if ($ks < $lowest_ks) {
				$lowest_ks = $ks;
				$lowest_line = $ks_values[$j];
				$query = $tabs3[0];
				$hit = $tabs3[1];
				$lowest_line_no = $j;
			}
		}
		splice (@ks_values,$lowest_line_no,1);
		foreach (@ks_values){
            		my @tabs7 = split /\t/, $_;
           	 	if ($tabs7[0] ne $query && $tabs7[0] ne $hit && $tabs7[1] ne $query && $tabs7[1] ne $hit){
  				push @ks_values_new, $_;
            		}
        	} 
		# average new branch lengths and calculate new se values for remaining branches
		@query_match = grep /$query/,@ks_values;
		@hit_match = grep /$hit/,@ks_values;
		foreach (@query_match){
			my $ks_new = 0;
			my $name = "_xx$hit\_yy$query\_zz";
			my $name2 = "";
			chomp $_;
			@tabs4 = split /\t/, $_;
			if ($tabs4[0] eq $query){
				my @greps = grep /$tabs4[1]/, @hit_match;
				if (scalar @greps){
					my @tabs5 = split /\t/, $greps[0];
					$ks_new = (($tabs4[2] + $tabs5[2]) / 2);
					my @temp = grep !/$tabs4[1]/, @hit_match;
					@hit_match = @temp;
				}
				else {
					$ks_new = $tabs4[2];
				}
				$name2 = $tabs4[1];
			}
			else {
				@greps = grep /$tabs4[0]/, @hit_match;
				if (scalar @greps){
					my @tabs5 = split /\t/, $greps[0];
					$ks_new = (($tabs4[2] + $tabs5[2]) / 2);
					my @temp = grep !/$tabs4[0]/, @hit_match;
					@hit_match = @temp;
				}
				else {
					$ks_new = $tabs4[2];
				}
				$name2 = $tabs4[0];
			}
			push @ks_values_new, "$name\t$name2\t$ks_new";
		}
		foreach (@hit_match){
			my $ks_new = 0;
			my $name = "_xx$hit\_yy$query\_zz";
			my $name2 = "";

			my @tabs6 = split /\t/, $_;
			my $ks_new = $tabs6[2];
			if ($tabs6[0] eq $hit){
				$name2 = $tabs6[1];
			}
			else {
				$name2 = $tabs6[0];
			}
			push @ks_values_new, "$name\t$name2\t$ks_new";
		}
		@ks_values = @ks_values_new;
	}
	$query =~ s/_xx/\(/g;
	$hit =~ s/_xx/\(/g;	
	$query =~ s/_yy/\,/g;
	$hit =~ s/_yy/\,/g;
	$query =~ s/_zz/\)/g;
	$hit =~ s/_zz/\)/g;
	return "\($query\,$hit\)";

}
