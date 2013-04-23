sub EvalSent {
    my ($BinModel, $SentRef, $GetPOSTags) = @_;
    my @Sent = @{$SentRef};
    
    my $OrigQty = @Sent;

    if ($GetPOSTags) {
    # First let's convert it to POS tags
        $Tmp1=`mktemp`;
        $Tmp2=`mktemp`;

        chomp $Tmp1;
        chomp $Tmp2;

        open F1, ">$Tmp1" or die("Cannot open $Tmp1");
        for my $s (@Sent) {
            $s =~ s/\n/ /mg;
            print F1 "$s\n";
        }
        close F1;

        0 == system("./POStagger.sh $Tmp1 $Tmp2") or die("POS tagger failed!");

        @Sent = ();

        open F2, "<$Tmp2" or die("Cannot open $Tmp2");
        while (<F2>) {
            chomp;
            push @Sent, $_;
        }
        close F2;

        if (@Sent != $OrigQty) {
            die("The # of retrieved sentences doesn't match the orig #! submitted: $OrigQty retrieved:".scalar(@Sent)); 
        }

        unlink $Tmp1;
        unlink $Tmp2;
    }

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
        my $perpl = 0;
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

sub Median {
    my $ArrRef = shift;

    my @a = sort { $a <=> $b } @$ArrRef;
    my $N = scalar(@a);
    my $m = int($N/2);
    if ($N % 2 != 0) {
        return $a[$m];
    }
    return undef if (!$N);

    return ($a[$m] + $a[$m - 1]) / 2;
}

sub Mean {
    my $ArrRef = shift;

    my @a = @$ArrRef;
    my $N = scalar(@a);
    my $sum = 0;

    for my $val (@a) {
        $sum += $val;
    }

    return $sum / $N;
}


sub STD {
    my $ArrRef = shift;

    my @a = @$ArrRef;
    my $N = scalar(@a);
    my $sum = 0;
    my $m = Mean($ArrRef);

    for my $val (@a) {
        $sum += ($val - $m)*($val - $m);
    }

    return sqrt($sum / $N);
}

1;
