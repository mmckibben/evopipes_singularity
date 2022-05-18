#!/usr/bin/perl

use warnings;
 use Bio::SeqIO;
    use Bio::Seq; 



 my $seq= <STDIN>;
 my $seqobjnuc = ();
$seqobjnuc = Bio::PrimarySeq->new ( -seq =>$seq ,
					     
					     );


my $seqobjprot = $seqobjnuc -> translate;



 if ($seqobjprot->seq=~/X/){
	
	my (@triplet)=();
	
	my @prot=split//,$seqobjprot->seq;
	
	#split nuc seq in codon (triplet), and omit stop codon
	my $tmpseq=$seqobjnuc->seq;
	while($tmpseq=~/(\w{3})/g){
	    my $codon=$1;
	    next if $codon=~/N\w\w/i || $codon=~/\wN\w/i || $codon=~/\w\wN/i;
	    push @triplet,$codon;
	}
	
	#update Bio::Seq object 
	$seqobjnuc->seq(join('',@triplet));
	$seqobjprot->seq($seqobjnuc->translate->seq);
    }


    
#print $seqobjprot->seq();
#PULL OUT THE NAMES OF EACH DNA SEQ FROM THE LIST AND THEN PRINT THEM TO THE BEGINNING OF THE FILE ALSO PUT A FAKE HEADER FOR THE FIRST ENTRY #N THE LIST SINCE IT SEEMS TO RUN WITH A FALSE START THAT WILL SCREW UP THE NAME ASSIGNMENT.
$LIST = "$ARGV[0]";
$name_count = "$ARGV[1]";
open LIST or die "No file $LIST";
@namelist = ();

while (<LIST>) {
push @namelist, $_;

}

$name = $namelist[$name_count];
print $name;

print $seqobjprot->seq();
print "\n";
