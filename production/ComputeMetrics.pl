#!/usr/bin/perl -w
my $ResFile = $ARGV[0] or die("Usage: <Res File> <Label File>");
my $LabelFile = $ARGV[1] or die("Usage: <Res File> <Label File>");

my @labs = ReadAll($LabelFile, '\n');
my @res  = ReadAll($ResFile, '\n');

print "Read lines #", scalar(@res), " lab #", scalar(@labs), "\n";

@res == scalar(@labs) or die("# of lines are different!");

my $acc = 0;
my $avgLog = 0;
my $i = 0;
for my $line (@res) {
    if ($line =~ /^\s*([0-9.]+)\s+([0-9.]+)\s+([01])\s*$/) {
        my $q = $1;
        my $p = $2;
        my $l = $3;

        if (abs($p + $q - 1)> 1e-4) {
            die("Probs don't sum up to 1 in: $line");
        }
        $acc += ($l == $labs[$i]);

        if ($labs[$i]) {
            $avgLog += log($p);
        } else {
            $avgLog += log($q);
        }
    } else {
        die("Wrong format: $line");
    }
    ++$i;
}
my $N = @res;
print "Accuracy: ".($acc/$N)." avg log: ".exp($avgLog/$N)." \n";
        
sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}
