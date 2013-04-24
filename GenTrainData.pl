#!/usr/bin/perl -w
#
# This script is used to generate additional training/validation data.
# It mimics input file and generates exactly the same # of fake and real examples.
# It also tries to make sentences with same lengths as in the example set.
#
use Eval;

srand(time());

#
sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <Example File> <Label File> <Binary Lang Model> <Real Sentence File> <Out File> <Out Label File>\n";
    exit 1
}

my $ExFile          = $ARGV[0] or Usage("Specify <Example File>");
my $LabelFile       = $ARGV[1] or Usage("Specify <Label File>");
my $BinLangModel    = $ARGV[2] or Usage("Specify <Binary Lang Model>");
my $RealSentFile    = $ARGV[3] or Usage("Specify <Real Sentence File>");
my $OutFile         = $ARGV[4] or Usage("Specify <Out File>");
my $OutLabelFile    = $ARGV[5] or Usage("Specify <Out Label File>");

my $qty = @ARGV;

my $DocSep = '~~~~~';
my @docs = ReadAll($ExFile, $DocSep);
# Delete the first elem, which is empty
shift @docs;
my @labs = ReadAll($LabelFile, '\n');

print "Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n";


my @RealSent = ReadAll($RealSentFile, '\n');
my $RealSentQty = scalar(@RealSent);

$|=1;

open(OD, ">$OutFile") or die("Cannot open output data file for writing!");
open(OL, ">$OutLabelFile") or die("Cannot open output label file for writing!");

for (my $n = 0; $n < @docs; ++$n) {
    my $lab = $labs[$n];

    print OL "$lab\n";
    
    my @tmps  = split(/\n/m, $docs[$n]);
    my $SentQty = @tmps;
    @tmps  = split(/\s+/m,   $docs[$n]);
    my $WordQty = @tmps;

    my $txt = "";
    
    if (!$lab) {
    # It's much easier to generate a fake sentence, we have a function for this!
        $txt = GenSent($BinLangModel, $WordQty);
    } else {
    # Harder to get a sequence of real sentences, because we will try to obtain a
    # 1) sentences going one after another
    # 2) starting from a random place
    # 3) having $WordQty words.
    # Which means that the last sentence may be truncated!

        while (1) {
            my $start = int(rand() * $RealSentQty);
            my @ww;
            for (my $j = $start; $j < $RealSentQty; ++$j) {
                @tmps  = split(/\s+/m,   $RealSent[$j]);
                for my $w (@tmps) {
                    if (@ww == $WordQty - 1) {
                        if ($w ne "<s>") {
                            push(@ww, "</s>");
                            last;
                        } else {
                            # Skip the sentence
                            last;
                        }
                    } else {
                        push(@ww, $w);
                    }
                }
                last if (@ww == $WordQty);
            }
            if (@ww == $WordQty) {
                $txt = join(" ", @ww);
                last;
            }
        }
    }

    print "Generated ".($n+1)." out of ".@docs."\n";

    $txt =~ s|</s>|</s>\n|gm;
    $txt =~ s|^\s+<s>|<s>|gm;

    print OD "$DocSep\n$txt";
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

