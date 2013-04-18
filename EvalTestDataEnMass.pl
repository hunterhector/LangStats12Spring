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
    print STDERR "Usage: <ModelFile> <Document file> <Label File> <Split docs into sentences?>\n";
    exit 1
}

my $ModelFile = $ARGV[0] or Usage("Specify <Model File>");
my $DocFile   = $ARGV[1] or Usage("Specify <Doc File>");
my $LabelFile = $ARGV[2] or Usage("Specify <Label File>");
my $SplitDocs = $ARGV[3];
defined($SplitDocs) or Usage("Specify <Split docs into sentences?>");

my @docs = ReadAll($DocFile, '~~~~~');
my @labs = ReadAll($LabelFile, '\n');
my $nFake = 0;
my $nReal = 0;
my $avgFake = 0;
my $avgReal = 0;

my @allSent;
my @allLab;

# First string will be empty
for (my $n = 1; $n < @docs; ++$n) {
    my @sents = split(/\n/m, $docs[$n]);
    my $lab = $labs[$n-1];
    if ($SplitDocs) {
        for my $txt (@sents) {
            next if ($txt =~ /^\s*$/);
            push(@allSent, $txt);
            push(@allLab, $lab);
        }
    } else {
        push(@allSent, $docs[$n]);
        push(@allLab, $lab);
    }
}

my @res = EvalSent($ModelFile, \@allSent);
        
for (my $i; $i < @res; ++$i) {
    my $perpl = $res[$i];
    my $lab   = $allLab[$i];
    my $txt   = $allSent[$i];
    next if (!defined($perpl));

    if ($lab) {
        $avgReal = ($avgReal * $nReal + $perpl) / ($nReal + 1);
        ++$nReal;
    } else {
        $avgFake = ($avgFake * $nFake + $perpl) / ($nFake + 1);
        ++$nFake;
    }

    print "$lab -> $perpl\n";
}

print "Real: $avgReal nReal = $nReal\n";
print "Fake: $avgFake nFake = $nFake\n";


sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}
