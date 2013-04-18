sub EvalSent {
    my ($BinModel, $SentRef) = @_;
    my @Sent = @{$SentRef};
    my @DelList;

    my @res;
    my $MainTempName = `mktemp`;
    chomp $MainTempName;
    push(@DelList, $MainTempName);

    open MT, ">$MainTempName" or die("Cannot open $MainTempName for writing.");

    for my $txt (@Sent) {
        my $TempName = `mktemp`;
        chomp $TempName;

        open T, ">$TempName" or die("Cannot open $TempName for writing.");
        print T $txt;
        close T;
        push(@DelList, $TempName);

        print MT "perplexity -text $TempName\n";
    }


    close MT;

    open P, "cat $MainTempName|ToolkitBin/evallm  -binary $BinModel  -context cue.ccs 2>&1| grep Perplexity|" or die("Cannot open the pipe!");

    my $n = 0;
    while (<P>) {
        chomp;
        my $line = $_;
        my $perpl = undef;
        ++$n;
        if ($line =~ /Perplexity = ([0-9.]+),/) {
            $perpl = $1;
        } else {
            print STDERR "Cannot parse perplexity in line $n! Got: $line\n";
        }
        push(@res, $perpl);
    }

    for my $dfn (@DelList) {
        unlink($dfn) or die("Cannot delete $dfn");
    }

    if (@res != @Sent) {
        die("Different # of source sentences and prplexities obatained: ".scalar(@res)." vs ".scalar(@Sent));
    }

    return @res;
}

1;
