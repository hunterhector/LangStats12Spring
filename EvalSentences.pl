#!/usr/bin/perl -w
#
# This script is used to compute average perplexity 
# For training and testing data.
#
use Eval;

sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <Model File> <Sent File> <Max Sent Qty>\n";
    exit 1
}

my $ModelFile = $ARGV[0] or Usage("Specify <Model File>");
my $SentFile   = $ARGV[1] or Usage("Specify <Sent File>");
my $MaxQty     = $ARGV[2] or Usage("Specify <MaxSent Qty>");

my @sents = ReadAll($SentFile, $MaxQty);

my $TempName = `mktemp`;
chomp $TempName;

my $nSent = 0;
my $avgPerpl = 0;

my @res = EvalSent($ModelFile, \@sents);

my @PerpArr;

for (my $n = 0; $n < @sents; ++$n) {
    my $perpl = $res[$n];
    next if (!defined($perpl));

    $avgPerpl = ($avgPerpl * $nSent + $perpl) / ($nSent + 1);
    ++$nSent;
    push(@PerpArr, $perpl); 
    #print "$perpl\n";
}

print "Perplexity: avg $avgPerpl median ".Median(\@PerpArr)." nSent = $nSent\n";

sub ReadAll {
    my ($nm, $MaxQty) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my @res;

    my $n = 0;
    while (<FD>) {
        chomp;
        push(@res, $_);
        ++$n;
        last if ($n >= $MaxQty);
    }

    return @res;
}
