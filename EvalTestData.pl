#!/usr/bin/perl -w
#
# This script is used to compute average perplexity 
# For training and testing data.
#
sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <ModelFile> <Document file> <Label File>\n";
    exit 1
}

my $ModelFile = $ARGV[0] or Usage("Specify <Model File>");
my $DocFile   = $ARGV[1] or Usage("Specify <Doc File>");
my $LabelFile = $ARGV[2] or Usage("Specify <Label File>");

my @docs = ReadAll($DocFile, '~~~~~');
my @labs = ReadAll($LabelFile, '\n');

my $TempName = `mktemp`;
chomp $TempName;

my $nFake = 0;
my $nReal = 0;
my $avgFake = 0;
my $avgReal = 0;

# First string will be empty
for (my $n = 1; $n < @docs; ++$n) {
    open T, ">$TempName" or die("Cannot open $TempName for writing.");
    print T $docs[$n];
    close T;
    my $res=`./EvalNGRAM.sh "$TempName" "$ModelFile"`;
    chomp $res;
    print "./EvalNGRAM.sh $TempName $ModelFile\n";
    my $lab = $labs[$n-1];
    my $perpl;
    if ($res =~ /Perplexity = ([0-9.]+),/) {
        $perpl = $1;
    } else {
        die("Unrecognized output: $res")
    }
    if ($lab) {
        $avgReal = ($avgReal * $nReal + $perpl) / ($nReal + 1);
        ++$nReal;
    } else {
        $avgFake = ($avgFake * $nFake + $perpl) / ($nFake + 1);
        ++$nFake;
    }
    
    print "$lab -> $perpl\n";
    unlink $TempName or die("Cannot delete a temp file $TempName");
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
