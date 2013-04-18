#!/usr/bin/perl -w
#
# This script is used to compute average perplexity 
# for data in the target format (docs separated by ~~~~~)
#
use Eval;

#
sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <Doc File> <Label File> <Out File> (<ModelFile> <FeatureName> <POS?>)+\n";
    exit 1
}

my $DocFile   = $ARGV[0] or Usage("Specify <Doc File>");
my $LabelFile = $ARGV[1] or Usage("Specify <Label File>");
my $OutFile   = $ARGV[2] or Usage("Specify <Out File>");
my $qty = @ARGV;

if (($qty - 3) % 3) {
    Usage("Wrong # of args!")
}

my @docs = ReadAll($DocFile, '~~~~~');
# Delete the first elem, which is empty
shift @docs;
my @labs = ReadAll($LabelFile, '\n');

print "Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n";


my @allSent;
my @allLab;

my $TotSentQty = 0;

my @WordQtys;

# First string will be empty
my $DocQty = @docs;

for (my $n = 0; $n < $DocQty; ++$n) {
    my $lab = $labs[$n];
    
    my @words = split(/[\n\s]+/m, $docs[$n]);
    my @tmps  = split(/\n/m,     $docs[$n]);
    my $WordQty = @words;
    my $SentQty = @tmps;
    push(@WordQtys, $WordQty);
    $TotSentQty += $SentQty;
    #print "$n -> $SentQty $WordQty\n";
    push(@allSent, $docs[$n]);
    push(@allLab, $lab);
}

print "Overall # of sentences: $TotSentQty\n";

my @FeatureNames = ("Label", "WordQty");
my @ModelResRef;

for (my $i = 3; $i + 2 <= $#ARGV; $i += 3) {
    my $ModelFile = $ARGV[$i];
    my $FeatureName = $ARGV[$i + 1];
    my $POS         = $ARGV[$i + 2];
    print "Evaluating  ($FeatureName) $ModelFile (pos?=$POS)\n";
    my @res = EvalSent($ModelFile, \@allSent, $POS);

    if (scalar(@res) != $DocQty) {
        die("Wrong # of results received for $ModelFile POS=$POS"); 
    }
    push(@FeatureNames, $FeatureName);
    push(@ModelResRef,  \@res); 
}

open O, ">$OutFile" or die("Cannot open $OutFile for writing!");

print O join(",", @FeatureNames)."\n"; 

for (my $j = 0; $j < $DocQty; ++$j) {
    my @vals = ($labs[$j], $WordQtys[$j]);

    for (my $k = 0; $k < @ModelResRef; ++$k) {
        push(@vals, $ModelResRef[$k]->[$j]);
    }

    print O join(",", @vals)."\n"; 
}

close O;
        
sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}
