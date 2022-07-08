# use perl sudoku_solver.pl <file>

$i = 0;
%graph = ();

@kwadranten = qw(
1 1 1 2 2 2 3 3 3
1 1 1 2 2 2 3 3 3
1 1 1 2 2 2 3 3 3
4 4 4 5 5 5 6 6 6
4 4 4 5 5 5 6 6 6
4 4 4 5 5 5 6 6 6
7 7 7 8 8 8 9 9 9
7 7 7 8 8 8 9 9 9
7 7 7 8 8 8 9 9 9);


@kleuren = qw(zwart rood oranje geel groen blauw indigo violet paars roze);
%kleuren_reverse = ();
for $i (0..$#kleuren) {
    $kleuren_reverse{$kleuren[$i]} = $i;
}

($outfile) = ($ARGV[0] =~ /sudokus[\\\/](.+)$/);
$outfile =~ s/\.txt/_s.txt/;

while (<>) {
    chomp;
    for $number (split / /) {
        $graph{$i}{'kleur'} = $kleuren[$number];
        $i++;
    }
}

sub onderzoek_knoop {
    my $knoop = shift;
    $i = 0;
    $row_start = $knoop - (int($knoop) % 9);
    $col_start = $knoop;
    $knoop_kleur = $graph{$knoop}{'kleur'};
    $kwadrant = $kwadranten[$knoop];
    if ($knoop_kleur ne "zwart") {
        while ($i < 9) {
            $graph{$row_start}{'onmogelijke kleuren'}{$knoop_kleur} = 1;
            $graph{$col_start}{'onmogelijke kleuren'}{$knoop_kleur} = 1;
            $row_start++;
            $col_start = ($col_start + 9) % 81;
            $i++;
        }
        for $j (0..$#kwadranten) {
            if ($kwadrant == $kwadranten[$j]) {
                $graph{$j}{'onmogelijke kleuren'}{$knoop_kleur} = 1;
            }
        }
    }
}

$start = time();

for $knoop (sort {int($a) <=> int($b) } keys %graph) {
    onderzoek_knoop($knoop);
}

@wachtrij = ();
sub vul_wachtrij {
    for $knoop (sort {int($a) <=> int($b) } keys %graph) {
        if ($graph{$knoop}{'kleur'} eq "zwart") {
            my %temp = map {($_, 1)} keys(%{$graph{$knoop}{'onmogelijke kleuren'}});
            my @verschil = grep {!$temp{$_} and $_ ne "zwart"} @kleuren;
            # print "$knoop: ".join(' ', @verschil)."\n";
            # verschil met de buren
            $i = 0;
            $row_start = $knoop - (int($knoop) % 9);
            $col_start = $knoop;
            my @buur_rij = ();
            my @buur_col = ();
            my @buur_kwadrant = ();
            $kwadrant = $kwadranten[$knoop];
            my @pointing_pair_gelijk_rij = ();
            my @pointing_pair_gelijk_col = ();
            my %pointing_pair_gelijk_rij_index = ();
            my %pointing_pair_gelijk_col_index = ();
            my %naked_pair_gelijk_rij_index = ();
            my %naked_pair_gelijk_col_index = ();
            my %hidden_pair_gelijk_rij_index = ();
            my %hidden_pair_gelijk_col_index = ();
            while ($i < 9) {
                my %buur_rij_temp = map {($_, 1)} keys(%{$graph{$row_start}{'onmogelijke kleuren'}});
                my %buur_col_temp = map {($_, 1)} keys(%{$graph{$col_start}{'onmogelijke kleuren'}});
                my @buur_rij_mogelijke_kleuren = grep {!$buur_rij_temp{$_} and $_ ne "zwart"} @kleuren;
                my @buur_col_mogelijke_kleuren = grep {!$buur_col_temp{$_} and $_ ne "zwart"} @kleuren;
                if ($row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart") {
                    push @buur_rij, @buur_rij_mogelijke_kleuren;
                }
                if ($col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart") {
                    push @buur_col, @buur_col_mogelijke_kleuren;
                }
                # ontdek pointing pairs in zelfde kwadrant
                @pointing_pair_gelijk_rij = ();
                @pointing_pair_gelijk_col = ();
                if ($row_start != int($knoop) and $kwadranten[$row_start] == $kwadrant and $graph{$row_start}{'kleur'} eq "zwart") {
                    my %pointing_pair_temp = map {($_, 1)} @buur_rij_mogelijke_kleuren;
                    @pointing_pair_gelijk_rij = grep {$pointing_pair_temp{$_}} @verschil;
                }
                if ($col_start != int($knoop) and $kwadranten[$col_start] == $kwadrant and $graph{$col_start}{'kleur'} eq "zwart") {
                    my %pointing_pair_temp = map {($_, 1)} @buur_col_mogelijke_kleuren;
                    @pointing_pair_gelijk_col = grep {$pointing_pair_temp{$_}} @verschil;
                }
                if (scalar(@pointing_pair_gelijk_rij) > 0) {
                    @{$pointing_pair_gelijk_rij_index{$row_start}} = @pointing_pair_gelijk_rij;
                }
                if (scalar(@pointing_pair_gelijk_col) > 0) {
                    @{$pointing_pair_gelijk_col_index{$col_start}} = @pointing_pair_gelijk_col;
                }
                # einde
                # ontdek hidden pairs
                @hidden_pair_gelijk_rij = ();
                @hidden_pair_gelijk_col = ();
                if ($row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart") {
                    my %hidden_pair_temp = map {($_, 1)} @buur_rij_mogelijke_kleuren;
                    @hidden_pair_gelijk_rij = grep {$hidden_pair_temp{$_}} @verschil;
                }
                if ($col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart") {
                    my %hidden_pair_temp = map {($_, 1)} @buur_col_mogelijke_kleuren;
                    @hidden_pair_gelijk_col = grep {$hidden_pair_temp{$_}} @verschil;
                }
                if (scalar(@hidden_pair_gelijk_rij) >= 2) {
                    @{$hidden_pair_gelijk_rij_index{$row_start}} = @hidden_pair_gelijk_rij;
                }
                if (scalar(@hidden_pair_gelijk_col) >= 2) {
                    @{$hidden_pair_gelijk_col_index{$col_start}} = @hidden_pair_gelijk_col;
                }
                # einde
                # ontdek naked pairs
                if ($row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart" and scalar(@buur_rij_mogelijke_kleuren) == 2 and scalar(@verschil) == 2) {
                    my %naked_pair_temp = map {($_, 1)} @buur_rij_mogelijke_kleuren;
                    my @naked_pair_gelijk_rij = grep {$naked_pair_temp{$_}} @verschil;
                    if (scalar(@naked_pair_gelijk_rij) == 2) {
                        @{$naked_pair_gelijk_rij_index{$row_start}} = @buur_rij_mogelijke_kleuren;
                    }
                }
                if ($col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart" and scalar(@buur_col_mogelijke_kleuren) == 2 and scalar(@verschil) == 2) {
                    my %naked_pair_temp = map {($_, 1)} @buur_col_mogelijke_kleuren;
                    my @naked_pair_gelijk_col = grep {$naked_pair_temp{$_}} @verschil;
                    if (scalar(@naked_pair_gelijk_col) == 2) {
                        @{$naked_pair_gelijk_col_index{$col_start}} = @buur_col_mogelijke_kleuren;
                    }
                }
                # einde
                $row_start++;
                $col_start = ($col_start + 9) % 81;
                $i++;
            }
            my %buur_rij_mogelijke_kleuren = map { $_ => 1 } @buur_rij;
            my %buur_col_mogelijke_kleuren = map { $_ => 1 } @buur_col;
            my %oude_pointing_pair_gelijk_col_index = ();
            my %oude_pointing_pair_gelijk_rij_index = ();
            while (($k, $v) = each(%pointing_pair_gelijk_col_index)) {
                @{$oude_pointing_pair_gelijk_col_index{$k}} = @{$v};
            }
            while (($k, $v) = each(%pointing_pair_gelijk_rij_index)) {
                @{$oude_pointing_pair_gelijk_rij_index{$k}} = @{$v};
            }
            for $j (0..$#kwadranten) {
                if ($kwadrant == $kwadranten[$j] and $j != int($knoop) and $graph{$j}{'kleur'} eq "zwart") {
                    my %buur_kwadrant_temp = map {($_, 1)} keys(%{$graph{$j}{'onmogelijke kleuren'}});
                    my @buur_kwadrant_mogelijke_kleuren = grep {!$buur_kwadrant_temp{$_} and $_ ne "zwart"} @kleuren;
                    push @buur_kwadrant, @buur_kwadrant_mogelijke_kleuren;
                    # test gelijke pointing pairs
                    while (($k, $v) = each(%pointing_pair_gelijk_col_index)) {
                        if (int($k) != $j) {
                            my %verschil_pointing_pair_temp = map {($_, 1)} @buur_kwadrant_mogelijke_kleuren;
                            @{$v} = grep {!$verschil_pointing_pair_temp{$_}} @{$v};
                        }
                    }
                    while (($k, $v) = each(%pointing_pair_gelijk_rij_index)) {
                        if (int($k) != $j) {
                            my %verschil_pointing_pair_temp = map {($_, 1)} @buur_kwadrant_mogelijke_kleuren;
                            @{$v} = grep {!$verschil_pointing_pair_temp{$_}} @{$v};
                        }
                    }
                    # einde
                }
            }
            my %buur_kwadrant_mogelijke_kleuren = map { $_ => 1 } @buur_kwadrant;
            # einde
            my @verschil_rij = grep {!$buur_rij_mogelijke_kleuren{$_}} @verschil;
            my @verschil_col = grep {!$buur_col_mogelijke_kleuren{$_}} @verschil;
            my @verschil_kwadrant = grep {!$buur_kwadrant_mogelijke_kleuren{$_}} @verschil;
            # print "verschil_rij: ".join(' ', @verschil_rij)."\n";
            # print "verschil_col: ".join(' ', @verschil_col)."\n";
            # print "verschil_kwadrant: ".join(' ', @verschil_kwadrant)."\n";
            if (scalar(@verschil) == 1) {
                $graph{$knoop}{'kleur'} = $verschil[0];
                onderzoek_knoop($knoop);
                push(@wachtrij, $knoop);
            } elsif (scalar(@verschil_rij) == 1) {
                $graph{$knoop}{'kleur'} = $verschil_rij[0];
                onderzoek_knoop($knoop);
                push (@wachtrij, $knoop);
            } elsif (scalar(@verschil_col) == 1) {
                $graph{$knoop}{'kleur'} = $verschil_col[0];
                onderzoek_knoop($knoop);
                push (@wachtrij, $knoop);
            } elsif (scalar(@verschil_kwadrant) == 1) {
                $graph{$knoop}{'kleur'} = $verschil_kwadrant[0];
                onderzoek_knoop($knoop);
                push (@wachtrij, $knoop);
            } else {
                # verwijder pointing pairs van de rest in kolom
                while (($k, $v) = each(%pointing_pair_gelijk_col_index)) {
                    if (scalar(@{$v}) == 1) {
                        $col_start = int($k);
                        $i = 0;
                        while ($i < 9) {
                            if ($col_start != int($k) and $col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart") {
                                $graph{$col_start}{'onmogelijke kleuren'}{$v->[0]} = 1;
                            }
                            $col_start = ($col_start + 9) % 81;
                            $i++;
                        }
                    }
                }
                # verwijder pointing pairs van de rest in rij
                while (($k, $v) = each(%pointing_pair_gelijk_rij_index)) {
                    if (scalar(@{$v}) == 1) {
                        $row_start = int($k) - (int($k) % 9);
                        $i = 0;
                        while ($i < 9) {
                            if ($row_start != int($k) and $row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart") {
                                $graph{$row_start}{'onmogelijke kleuren'}{$v->[0]} = 1;
                            }
                            $row_start++;
                            $i++;
                        }
                    }
                }
                # verwijder pointing pairs van zelfde col in kwadrant
                while (($k, $v) = each(%oude_pointing_pair_gelijk_col_index)) {
                    $col_start = int($k);
                    $i = 0;
                    while ($i < 9) {
                        if ($col_start != int($k) and $col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart") {
                            my %buur_col_mogelijke_kleuren_temp = map {($_, 1)} keys %{$graph{$col_start}{'onmogelijke kleuren'}};
                            my @buur_col_mogelijke_kleuren = grep {!$buur_col_mogelijke_kleuren_temp{$_} and $_ ne "zwart"} @kleuren;
                            my %buur_col_gelijk_kleuren = map {($_, 1)} @buur_col_mogelijke_kleuren;
                            @{$v} = grep {!$buur_col_gelijk_kleuren{$_}} @{$v};
                        }
                        $col_start = ($col_start + 9) % 81;
                        $i++;
                    }
                    if (scalar(@{$v}) == 1) {
                        # hier
                        for $j (0..$#kwadranten) {
                            if ($kwadranten[int($knoop)] == $kwadranten[$j] and $j != int($knoop) and $j != int($k) and $graph{$j}{'kleur'} eq "zwart") {
                                $graph{$j}{'onmogelijke kleuren'}{$v->[0]} = 1;
                            }
                        }
                    }
                }
                # verwijder pointing pairs van zelfde rij in kwadrant
                while (($k, $v) = each(%oude_pointing_pair_gelijk_rij_index)) {
                    $row_start = int($k) - (int($k) % 9);
                    $i = 0;
                    while ($i < 9) {
                        if ($row_start != int($k) and $row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart") {
                            my %buur_rij_mogelijke_kleuren_temp = map {($_, 1)} keys %{$graph{$row_start}{'onmogelijke kleuren'}};
                            my @buur_rij_mogelijke_kleuren = grep {!$buur_rij_mogelijke_kleuren_temp{$_} and $_ ne "zwart"} @kleuren;
                            my %buur_rij_gelijk_kleuren = map {($_, 1)} @buur_rij_mogelijke_kleuren;
                            @{$v} = grep {!$buur_rij_gelijk_kleuren{$_}} @{$v};
                        }
                        $row_start++;
                        $i++;
                    }
                    if (scalar(@{$v}) == 1) {
                        for $j (0..$#kwadranten) {
                            if ($kwadranten[int($knoop)] == $kwadranten[$j] and $j != int($knoop) and $j != int($k) and $graph{$j}{'kleur'} eq "zwart") {
                                $graph{$j}{'onmogelijke kleuren'}{$v->[0]} = 1;
                            }
                        }
                    }
                }
                # verwijder naked pairs van de rest van de kolom
                while (($k, $v) = each(%naked_pair_gelijk_col_index)) {
                    $col_start = int($k);
                    $i = 0;
                    while ($i < 9) {
                        if ($col_start != int($k) and $col_start != int($knoop) and $graph{$col_start}{'kleur'} eq "zwart") {
                            for $kleur (@{$v}) {
                                $graph{$col_start}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                        $col_start = ($col_start + 9) % 81;
                        $i++;
                    }
                }
                # verwijder naked pairs van de rest in rij
                while (($k, $v) = each(%naked_pair_gelijk_rij_index)) {
                    $row_start = int($k) - (int($k) % 9);
                    $i = 0;
                    while ($i < 9) {
                        if ($row_start != int($k) and $row_start != int($knoop) and $graph{$row_start}{'kleur'} eq "zwart") {
                            for $kleur(@{$v}) {
                                $graph{$row_start}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                        $row_start++;
                        $i++;
                    }
                }
                # check hidden pairs
                while (($k, $v) = each(%hidden_pair_gelijk_rij_index)) {
                    $row_start = int($knoop) - (int($knoop) % 9);
                    $i = 0;
                    my %buren_rij_kleuren = ();
                    while ($i < 9) {
                        if ($row_start != int($knoop) and $row_start != int($k) and $graph{$row_start}{'kleur'} eq "zwart") {
                            my %buur_rij_temp = map {($_, 1)} keys(%{$graph{$row_start}{'onmogelijke kleuren'}});
                            my @buur_rij_mogelijke_kleuren = grep {!$buur_rij_temp{$_} and $_ ne "zwart"} @kleuren;
                            for $kleur (@buur_rij_mogelijke_kleuren) {
                                $buren_rij_kleuren{$kleur} = 1;
                            }
                        }
                        $row_start++;
                        $i++;
                    }
                    my @buren_rij_verschil_kleuren = grep {!$buren_rij_kleuren{$_}} @{$v};
                    if (scalar(@buren_rij_verschil_kleuren) == 2) {
                        %buren_rij_verschil_kleuren_temp = map {($_, 1)} @buren_rij_verschil_kleuren;
                        for $kleur (@verschil) {
                            if (!$buren_rij_verschil_kleuren_temp{$kleur}) {
                                $graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                        my %buur_rij_temp = map {($_, 1)} keys(%{$graph{$k}{'onmogelijke kleuren'}});
                        my @buur_rij_mogelijke_kleuren = grep {!$buur_rij_temp{$_} and $_ ne "zwart"} @kleuren;
                        for $kleur (@buur_rij_mogelijke_kleuren) {
                            if (!$buren_rij_verschil_kleuren_temp{$kleur}) {
                                $graph{$k}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                    }
                }
                while (($k, $v) = each(%hidden_pair_gelijk_col_index)) {
                    $col_start = int($knoop);
                    $i = 0;
                    my %buren_col_kleuren = ();
                    while ($i < 9) {
                        if ($col_start != int($knoop) and $col_start != int($k) and $graph{$col_start}{'kleur'} eq "zwart") {
                            my %buur_col_temp = map {($_, 1)} keys(%{$graph{$col_start}{'onmogelijke kleuren'}});
                            my @buur_col_mogelijke_kleuren = grep {!$buur_col_temp{$_} and $_ ne "zwart"} @kleuren;
                            for $kleur (@buur_col_mogelijke_kleuren) {
                                $buren_col_kleuren{$kleur} = 1;
                            }
                        }
                        $col_start = ($col_start + 9) % 81;
                        $i++;
                    }
                    my @buren_col_verschil_kleuren = grep {!$buren_col_kleuren{$_}} @{$v};
                    if (scalar(@buren_col_verschil_kleuren) == 2) {
                        %buren_col_verschil_kleuren_temp = map {($_, 1)} @buren_col_verschil_kleuren;
                        for $kleur (@verschil) {
                            if (!$buren_col_verschil_kleuren_temp{$kleur}) {
                                $graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                        my %buur_col_temp = map {($_, 1)} keys(%{$graph{$k}{'onmogelijke kleuren'}});
                        my @buur_col_mogelijke_kleuren = grep {!$buur_col_temp{$_} and $_ ne "zwart"} @kleuren;
                        for $kleur (@buur_col_mogelijke_kleuren) {
                            if (!$buren_col_verschil_kleuren_temp{$kleur}) {
                                $graph{$k}{'onmogelijke kleuren'}{$kleur} = 1;
                            }
                        }
                    }
                }
                # einde
            }
        }
    }
}

vul_wachtrij();

$iteratie = 1;

while (scalar(@wachtrij) > 0) {
    $knoop = shift(@wachtrij);
    # print "\n\niteratie $iteratie knoop $knoop wordt onderzocht\n";
    onderzoek_knoop($knoop);
    vul_wachtrij();
    # print_sudoku();
    # $iteratie++;
}

# brute force code
sub print_sudoku {
    $i = 0;
    for $knoop (sort {int($a) <=> int($b) } keys %graph) {
        print "$kleuren_reverse{$graph{$knoop}{'kleur'}} ";
        if (($i+1) % 27 == 0 and ($i+1) <= 54) {
            print " = 0,45\n---------------------\n";
        } elsif (($i+1) % 9 == 0) {
            print " = 0,45\n";
        } elsif (($i+1) % 3 == 0) {
            print "| ";
        }
        $i++;
    }
}

sub check_op_zwarte_knoop {
    my $meeste_aantal = 0;
    my $minste_knoop;
    for $knoop (sort {int($a) <=> int($b) } keys %graph) {
        $knoop_kleur = $graph{$knoop}{'kleur'};
        if ($knoop_kleur eq "zwart" and scalar(keys %{$graph{$knoop}{'onmogelijke kleuren'}}) > $meeste_aantal) {
            $minste_knoop = $knoop;
            $meeste_aantal = scalar(keys %{$graph{$knoop}{'onmogelijke kleuren'}});
        }
    }
    if ($minste_knoop) {
        return $minste_knoop;
    }
}

%temp_graph = ();
for $knoop (sort {int($a) <=> int($b) } keys %graph) {
    $temp_graph{$knoop}{'kleur'} = $graph{$knoop}{'kleur'};
    for $kleur (keys %{$graph{$knoop}{'onmogelijke kleuren'}}) {
        $temp_graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
    }
}
sub brute_force {
    my $kn = shift;
    my %temp = map {($_, 1)} keys(%{$graph{$kn}{'onmogelijke kleuren'}});
    my @verschil = grep {!$temp{$_} and $_ ne "zwart"} @kleuren;
    # for $knoop (sort {int($a) <=> int($b) } keys %graph) {
    #     $temp_graph{$knoop}{'kleur'} = $graph{$knoop}{'kleur'};
    # }
    my %temp_graph_2 = ();
    for $knoop (sort {int($a) <=> int($b) } keys %graph) {
        $temp_graph_2{$knoop}{'kleur'} = $graph{$knoop}{'kleur'};
        for $kleur (keys %{$graph{$knoop}{'onmogelijke kleuren'}}) {
            $temp_graph_2{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
        }
    }
    for $kleur (@verschil) {
       my $zw_kn = check_op_zwarte_knoop();
       if (!$zw_kn) {
           last;
       }
       $graph{$kn}{'kleur'} = $kleur;
       push @wachtrij, $kn;
        while (scalar(@wachtrij) > 0) {
            $knoop = shift(@wachtrij);
            onderzoek_knoop($knoop);
            vul_wachtrij();
        }
        $zw_kn = check_op_zwarte_knoop();
        if (!$zw_kn) {
            last;
        } elsif (scalar(keys %{$graph{$zw_kn}{'onmogelijke kleuren'}}) < 9) {
            for $knoop (sort {int($a) <=> int($b) } keys %graph) {
                $temp_graph{$knoop}{'kleur'} = $graph{$knoop}{'kleur'};
                %{$temp_graph{$knoop}{'onmogelijke kleuren'}} = ();
                for $kleur (keys %{$graph{$knoop}{'onmogelijke kleuren'}}) {
                    $temp_graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
                }
            }
            brute_force($zw_kn);
            $zw_kn = check_op_zwarte_knoop();
            if (!$zw_kn) {
                last;
            } else {
                for $knoop (sort {int($a) <=> int($b) } keys %graph) {
                    $graph{$knoop}{'kleur'} = $temp_graph_2{$knoop}{'kleur'};
                    %{$graph{$knoop}{'onmogelijke kleuren'}} = ();
                    for $kleur (keys %{$temp_graph_2{$knoop}{'onmogelijke kleuren'}}) {
                        $graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
                    }
                }
            }
        } else {
            for $knoop (sort {int($a) <=> int($b) } keys %graph) {
                $graph{$knoop}{'kleur'} = $temp_graph_2{$knoop}{'kleur'};
                %{$graph{$knoop}{'onmogelijke kleuren'}} = ();
                for $kleur (keys %{$temp_graph_2{$knoop}{'onmogelijke kleuren'}}) {
                    $graph{$knoop}{'onmogelijke kleuren'}{$kleur} = 1;
                }
            }
        }
    }
}

$zwarte_knoop = check_op_zwarte_knoop();
%zwarte_lijst = ();
if ($zwarte_knoop) {
    my %temp_graph = %graph;
    brute_force($zwarte_knoop);
    $zwarte_knoop = check_op_zwarte_knoop();
}


open OUT, ">", $outfile or die "$!\n";

$i = 0;
print "\n";
for $knoop (sort {int($a) <=> int($b) } keys %graph) {
    print OUT "$kleuren_reverse{$graph{$knoop}{'kleur'}} ";
    print "$kleuren_reverse{$graph{$knoop}{'kleur'}} ";
    if (($i+1) % 27 == 0 and ($i+1) <= 54) {
        print OUT " = 0,45\n---------------------\n";
        print " = 0,45\n---------------------\n";
    } elsif (($i+1) % 9 == 0) {
        print OUT " = 0,45\n";
        print " = 0,45\n";
    } elsif (($i+1) % 3 == 0) {
        print OUT "| ";
        print "| ";
    }
    $i++;
}
print "\n";
print OUT "\n0 0 0 0 0 0 0 0 0 ";
print OUT "\n45 45 45 45 45 45 45 45 45 \n";
print "\n0 0 0 0 0 0 0 0 0 ";
print "\n45 45 45 45 45 45 45 45 45 ";
print "\n";

$stop = time();

open OUT_TIME, ">>", "time_optimized.csv" or die "$!\n";
print "\ntime: ".($stop - $start)."\n";
print OUT_TIME "$outfile,".($stop - $start)."\n";
close OUT_TIME;
