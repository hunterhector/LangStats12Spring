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
# Delete the first elem, which is empty
shift @docs;
my @labs = ReadAll($LabelFile, '\n');

#die("Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n");
print "Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n";


my @allSent;
my @allLab;

# First string will be empty
for (my $n = 0; $n < @docs; ++$n) {
    my $lab = $labs[$n];
    if ($SplitDocs) {
        my @sents = split(/\n/m, $docs[$n]);
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
my @FakePerpl;
my @RealPerpl;
        
for (my $i = 0; $i < @res; ++$i) {
    my $perpl = $res[$i];
    my $lab   = $allLab[$i];
    my $txt   = $allSent[$i];
    next if (!defined($perpl));

    if (0 == $lab) {
        push(@FakePerpl, $perpl);
    } else {
        push(@RealPerpl, $perpl);
    }

    print "$lab -> $perpl\n";
}

my $nReal = scalar(@RealPerpl);
my $nFake = scalar(@FakePerpl);
my $avgReal = Mean(\@RealPerpl);
my $avgFake = Mean(\@FakePerpl);
my $stdReal = STD(\@RealPerpl);
my $stdFake = STD(\@FakePerpl);
my $medReal = Median(\@RealPerpl);
my $medFake = Median(\@FakePerpl);

print "REAL mean: $avgReal STD: $stdReal median: $medReal nReal = $nReal\n";
print "FAKE mean: $avgFake STD: $stdFake median: $medFake nFake = $nFake\n";


sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}
