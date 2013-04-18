#!/usr/bin/perl -w
#
# This script is used to compute average perplexity 
# For training and testing data.
#
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

# First string will be empty
for (my $n = 0; $n < @sents; ++$n) {
    open T, ">$TempName" or die("Cannot open $TempName for writing.");
    print T $sents[$n];
    close T;
    my $res=`./EvalNGRAM.sh "$TempName" "$ModelFile"`;
    chomp $res;
    print "./EvalNGRAM.sh $TempName $ModelFile\n";
    my $perpl;
    if ($res =~ /Perplexity = ([0-9.]+),/) {
        $perpl = $1;
        $avgPerpl = ($avgPerpl * $nSent + $perpl) / ($nSent + 1);
        ++$nSent;
        print "$perpl\n";
        unlink $TempName or die("Cannot delete a temp file $TempName");
    } else {
        print STDERR "Unrecognized output: $res, ignoring setence:\n$sents[$n]\n";
    }
}

print "Perplexity: $avgPerpl nSent = $nSent\n";


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
