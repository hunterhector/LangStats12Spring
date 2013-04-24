#!/usr/bin/perl -w
#
# This script is used to generate additional training/validation data.
#
use Eval;

#
sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <Filter words file> <Trainig File> <Label File> <Fake Sentence File> <Real Sentence File> <# of examples> <Out Doc File> <Out Label File>\n";
    exit 1
}

my $FilterWordFile= $ARGV[0] or Usage("Specify <Filter words File>");
my $DocFile   = $ARGV[1] or Usage("Specify <Doc File>");
my $LabelFile = $ARGV[2] or Usage("Specify <Label File>");
my $FakeSentFile  = $ARGV[3] or Usage("Specify <Fake Sentence File>");
my $RealSentFile  = $ARGV[4] or Usage("Specify <Real Sentence File>");
my $NumSample = $ARGV[5] or Usage("Specify <# of examples>");
my $OutFile   = $ARGV[6] or Usage("Specify <Out Doc File>");
my $OutLabelFile = $ARGV[7] or Usage("Specify <Out Label File>");

my $qty = @ARGV;

my $DocSep = '~~~~~';
my @docs = ReadAll($DocFile, $DocSep);
# Delete the first elem, which is empty
shift @docs;
my @labs = ReadAll($LabelFile, '\n');

my @FilterWords = ReadAll($FilterWordFile, '\n');
my %FilterHash;

for my $w (@FilterWords) {
    $FilterHash{$w} = 1;
}

print "Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n";


my @FakeSent = ReadAll($FakeSentFile, '\n');
my @RealSent = ReadAll($RealSentFile, '\n');

my @SentRef = (\@FakeSent, \@RealSent);

my @WordQtys;

my %DocLenDistr0;
my %DocLenDistr1;

my @DocLenDistr = (\%DocLenDistr0, \%DocLenDistr1);
my @TotSentQty    = (0, 0);

# First string will be empty
my $DocQty = @docs;

for (my $n = 0; $n < $DocQty; ++$n) {
    my $lab = $labs[$n];
    
    my @tmps  = split(/\n/m,     $docs[$n]);
    my $SentQty = @tmps;

    $TotSentQty[$lab]++;

    my $HashRef = $DocLenDistr[$lab];
    $HashRef->{$SentQty} ++;;
}

open(OD, ">$OutFile") or die("Cannot open output data file for writing!");
open(OL, ">$OutLabelFile") or die("Cannot open output label file for writing!");

print "Overall # of sentences: $TotSentQty[0] $TotSentQty[1]\n";


$|=1;
for (my $i = 0; $i < $NumSample; ++$i) {
    for (my $lab = 0; $lab <= 1; ++$lab) {
        my $len;
        my $r = rand() *  $TotSentQty[$lab];
        my %hash = %{$DocLenDistr[$lab]};
        my @sent = @{$SentRef[$lab]};
        my $SN = @sent;
        my $sum = 0;

        for my $k (keys(%hash)) {
            $sum += $hash{$k};
            if ($sum >= $r) {
                $len = $k; 
                last;
            } 
        }
        print "#$i $lab -> $len\n";
        print OD "$DocSep\n";
        for (my $k = 0; $k < $len; ++$k) {
            my $sn = int(rand() * scalar(@sent));
            my $txt = GetFilteredSent($sent[$sn]);
            print OD "$txt\n";
        }
        print OL "$lab\n"; 
    }
}

close OD or die("cannot close data");
close OL or die("cannot close labels");
        
sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}

sub GetFilteredSent {
    my $sent = shift;

    my @tmps  = split(/\s+/m, $sent);
    my @res;

    for my $w (@tmps) {
        if (exists $FilterHash{$w}) {
            push @res, $w;
        } else {
            push @res, "<UNK>";
        }
    }

    return join(" ", @res);
}
