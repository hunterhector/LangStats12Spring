#!/usr/bin/perl -w
#
# This script is used to split dev data with respect to sentence length.
#
use Eval;

#
sub Usage {
    my $err = shift;
    print "$err\n";
    print STDERR "Usage: <Doc File> <Label File> <Out File Prefix>";
    exit 1
}

my $DocFile   = $ARGV[0] or Usage("Specify <Doc File>");
my $LabelFile = $ARGV[1] or Usage("Specify <Label File>");
my $OutFilePrefix= $ARGV[2] or Usage("Specify <Out File Prefix>");


my @docs = ReadAll($DocFile, '~~~~~');
# Delete the first elem, which is empty
shift @docs;
my @labs = ReadAll($LabelFile, '\n');

print "Read docs #", scalar(@docs), " lab #", scalar(@labs), "\n";

# First string will be empty
my $DocQty = @docs;

my  @OutFileDoc;
my  @OutFileLab;

for (my $n = 0; $n < $DocQty; ++$n) {
    my @tmps  = split(/\n/m,     $docs[$n]);
    shift @tmps;
    my $SentQty = @tmps;

    my $f1 = $OutFileDoc[$SentQty];
    my $f2 = $OutFileLab[$SentQty];

    if (!defined($f1)) {
        open($f1, ">${OutFilePrefix}${SentQty}.dat");
        open($f2, ">${OutFilePrefix}Label${SentQty}.dat");
        $OutFileDoc[$SentQty] = $f1;
        $OutFileLab[$SentQty] = $f2;
    }

    print $f1 "~~~~~$docs[$n]";
    print $f2 $labs[$n]."\n";
}

sub ReadAll {
    my ($nm, $splitStr) = @_;
    open FD, "<$nm" or die("Cannot open $nm for reading.");

    my $txt = "";

    while (<FD>) {
        $txt .= $_;
    }

    my @res = split(/$splitStr/m, $txt);
}
