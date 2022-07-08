($outfile) = ($ARGV[0] =~ /sudokus[\\\/](.+)$/);
$outfile =~ s/\.txt/_s.txt/;
@grid = ();
while (<>) {
    chomp;
    @{$grid[$i]} = ();
    for $n (split / /) {
        $grid[$i][$j++] = $n;
    }
    $j = 0;
    $i++;
}

sub possible {
    (my $x, my $y, my $n) = @_;
    for $i (0..8) {
        if ($grid[$x][$i] == $n) {
            return 0;
        }
    }
    for $i (0..8) {
        if ($grid[$i][$y] == $n) {
            return 0;
        }
    }
    $x0 = $x - $x % 3;
    $y0 = $y - $y % 3;
    for $i (0..2) {
        for $j (0..2) {
            if ($grid[$x0 + $i][$y0 + $j] == $n) {
                return 0;
            }
        }
    }
    return 1;
}

sub solve {
    for $x (0..8) {
        for $y (0..8) {
            if ($grid[$x][$y] == 0) {
                for $n (1..9) {
                    if (possible($x, $y, $n) == 1) {
                        $grid[$x][$y] = $n;
                        solve();
                        $grid[$x][$y] = 0;
                    }
                }
                return;
            }

        }
    }
    print_grid_to_file();
}

sub print_grid_to_file {
    open OUT, ">", $outfile or die "$!\n";
    for $x (0..8) {
        for $y (0..8) {
            print OUT "$grid[$x][$y] ";
            print "$grid[$x][$y] ";
            if ($y % 3 == 2 and $y < 8) {
                print OUT "| ";
                print "| ";
            }
        }
        if ($x % 3 == 2 and $x < 8) {
            print OUT " = 0,45\n---------------------\n";
            print " = 0,45\n---------------------\n";
        } else {
            print OUT " = 0,45\n";
            print " = 0,45\n";
        }
    }
    print "\n";
    print OUT "\n0 0 0 0 0 0 0 0 0 ";
    print OUT "\n45 45 45 45 45 45 45 45 45 \n";
    print "\n0 0 0 0 0 0 0 0 0 ";
    print "\n45 45 45 45 45 45 45 45 45 ";
    print "\n";
    close OUT;
}

$start = time();
solve();
$stop = time();
open OUT_TIME, ">>", "time.csv" or die "$!\n";
print "\ntime: ".($stop - $start)."\n";
print OUT_TIME "$outfile,".($stop - $start)."\n";
close OUT_TIME;
