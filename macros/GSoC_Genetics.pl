# Generate a random DNA Sequence
# Usage: Genetics_RandomDNASequence( length )
#   length: a self-explanatory number
#   returns a self-explanatory string
sub Genetics_RandomDNASequence {
	my ($l) = @_;
	my $o = '';

	SRAND($problemSeed);
	++$l;
	while(--$l) {
		my $p = random(0, 3);
		$o .= $p;
	}
	$o =~ tr/0123/ACGT/;
	return $o;
}

# Calculate the GC content of a given sequence
# Usage: Genetics_GCContent( sequence )
#   sequence: text string with the nucleotide sequence assuming the following valid characters: ACGT
#   returns a number between 0 (no G/C) and 1 (no A/T)
sub Genetics_GCContent {
	my ($s) = @_;
	$s = uc($s);
	$l = length($s);
	$s =~ s/[AT]//g;
	return length($s)/$l;
}

# Creates a pedigree string with a format suitable to feed Genetics_DrawPedigree
# Usage: Genetics_RandomPedigree( seed, generations, boy_girl, will_have_children, min_number_of_children, max_number_of_children, inheritance )
#   seed: a number that is used to generate different but identifiable random trees
#   generations: the depth of the pedigree in generations
#   boy_girl: a number between 0 and 1 that defines the ratio between boys and girls; 0: all boys, 1: all girls
#   will_have_children: a number between 0 and 1 that defines the chance of an individual to have or not have children; 0: will not have children, 1: will have children
#   min_number_of_children: a positive number that defines the minimum amount of children that an individual may have
#   max_number_of_children: a positive number that defines the maximum amount of children that an individual may have
#   inheritance: a string that, when specified, simulates a trait following a particular inheritance pattern
#     possible values are: 'autosomic dominant', 'autosomic recessive', 'x-linked', 'y-linked', 'mitochondrial'
#   returns a self-explanatory string
sub Genetics_RandomPedigree {
	my ($seed, $gen_n, $bg, $ch, $ch_min, $ch_max, $inheritance, $_gen_n, $_genotype) = @_;
	if(!defined $inheritance) { $inheritance = ''; }
	if(!defined $_gen_n) { $_gen_n = 0; }
	if(!defined $_genotype) { $_genotype = {}; }

	SRAND($seed);
	my $s = '(';
	if($gen_n > 0) {
		my $sex = random(0, 1, 0.000001) > $bg ? 'M' : 'F';
		$s .= $sex;
		my $__genotype;
		if($_gen_n == 0) {
			if($inheritance eq 'autosomic dominant') {
				$__genotype->{$sex} = 'Xx';
				$__genotype->{_sex_not($sex)} = 'xx';
			}
			if($inheritance eq 'autosomic recessive') {
				$__genotype->{$sex} = 'Xx';
				$__genotype->{_sex_not($sex)} = 'Xx';
			}
			if($inheritance eq 'x-linked') {
				$__genotype->{'F'} = 'XX';
				$__genotype->{'M'} = 'X';
			}
			if($inheritance eq 'y-linked') {
				$__genotype->{'M'} = 'XY';
				$__genotype->{'F'} = '';
			}
			if($inheritance eq 'mitochondrial') {
				$__genotype->{$sex} = 'X';
				$__genotype->{_sex_not($sex)} = 'x';
			}
		} else { $__genotype = _calculate_genotype($inheritance, $sex, $_genotype); }
		$s .= _calculate_phenotype($inheritance, $sex, $__genotype) == 0 ? '' : 'X';
		if($gen_n > 1) {
			$s .= ',' . _sex_not($sex) . (_calculate_phenotype($inheritance, _sex_not($sex), $__genotype) == 0 ? '' : 'X') . ',(';
			$_ch_n = random($ch_min, $ch_max);
			my $_ch_n_i = random(0, $_ch_n-1);
			my $i = 0;
			for(;$i<$_ch_n;++$i) {
				if(($gen_n > 2)&&(($i == $_ch_n_i)||(random(0, 1, 0.000001) > $ch))) {
					$s .= ($i == 0 ? '' : ',') . Genetics_RandomPedigree(random(1, 1000000), $gen_n-1, $bg, $ch, $ch_min, $ch_max, $inheritance, $_gen_n+1, $__genotype);
				} else {
					my $_sex = (random(0, 1, 0.000001) > $bg) ? 'M' : 'F';
					$___genotype = _calculate_genotype($inheritance, $_sex, $__genotype);
					$s .= ($i == 0 ? '' : ',') . $_sex . (_calculate_phenotype($inheritance, $_sex, $___genotype) == 0 ? '' : 'X');
				}
			}
			$s .= ')';
		}

	}
	$s .= ')';
	return $s;
}

# Renders the given string in the 'pedigree' format (explained below)
# Usage: Genetics_DrawPedigree( pedigree )
#   pedigree: text string representing the respective pedigree
#   returns an html string that contains the rendered pedigree
sub Genetics_DrawPedigree {
	my ($s) = @_;
	$s =~ s/ //g;

	# example tree
	# (M, F, (                                                                                ))
	#         M, (                                                     ), (               ), F
	#             M, F, (                                             )    F, M, (       )
	#                    F, (                                  ), M, M            F, M, F
	#                        M, F, (                          )
	#                               F, M, F, (               )
	#                                         F, M, (       )
	#                                                M, M, M

	# my %root = ('l' => 'M', 'r' => 'F', 'x' => 0, 'y' => 0, 'w' => 540,
	# 	'c' => [
	# 			{'l' => 'M', 'x' => 0, 'w' => 20},
	# 			{'l' => 'M', 'r' => 'F', 'x' => 40, 'w' => 340,
	# 				'c' => [
	# 						{'l' => 'F', 'x' => 0, 'w' => 20},
	# 						{'l' => 'M', 'r' => 'F', 'x' => 40, 'w' => 220,
	# 							'c' => [
	# 									{'l' => 'F', 'x' => 0, 'w' => 20},
	# 									{'l' => 'M', 'x' => 40, 'w' => 20},
	# 									{'l' => 'F', 'x' => 80, 'w' => 20},
	# 									{'l' => 'F', 'r' => 'M', 'x' => 120, 'w' => 100,
	# 										'c' => [
	# 												{'l' => 'M', 'x' => 0, 'w' => 20},
	# 												{'l' => 'M', 'x' => 40, 'w' => 20},
	# 												{'l' => 'M', 'x' => 80, 'w' => 20}
	# 											]}
	# 								]},
	# 						{'l' => 'M', 'x' => 280, 'w' => 20},
	# 						{'l' => 'M', 'x' => 320, 'w' => 20}
	# 					]},
	# 			{'l' => 'F', 'r' => 'M', 'x' => 400, 'w' => 100,
	# 				'c' => [
	# 						{'l' => 'F', 'x' => 0, 'w' => 20},
	# 						{'l' => 'M', 'x' => 40, 'w' => 20},
	# 						{'l' => 'F', 'x' => 80, 'w' => 20}
	# 					]},
	# 			{'l' => 'F', 'x' => 520, 'w' => 20}
	# 		]);

	# my $tree = _parse_pedigree_string('(MX,F,(MX,(M,FX,(F,(M,FX,(F,MX,F,(F,MX,(M,MX,M)))),M,MX)),(F,M,(FX,MX,FX)),F))'); # D
	my $tree = _parse_pedigree_string($s);
	return '<div style="background-color: #EEE; height: ' . ($tree->{'h'}+2) . 'px; overflow: hidden; position: relative; width: ' . ($tree->{'w'}+2) . 'px;">' . _render_pedigree_tree($tree, 0) . '</div>';
}

# Translates the given DNA sequence to its corresponding RNA sequence
# Usage: Genetics_TranscriptDNASequence( sequence )
#   sequence: text string with the nucleotide sequence assuming the following valid characters: ACGt
#   returns a string with the corresponding RNA sequence that would result from transcription
sub Genetics_TranscriptDNASequence {
	my ($sequence) = @_;

	$sequence =~ s/T/U/g;
	return $sequence;
}

# Translates the given RNA sequence to its corresponding DNA sequence using the standard genetic code
# Usage: Genetics_TranslateRNASequence( sequence )
#   sequence: text string with the nucleotide sequence assuming the following valid characters: ACGU
#   returns a string with the corresponding translated aminoacid sequence
sub Genetics_TranslateRNASequence {
	my ($sequence) = @_;

	my $aa = '';
	my $i = 0;
	while(($i+3) <= length($sequence)) {
		my $codon = substr($sequence, $i, 3);
		if($codon eq 'UUU') { $aa .= 'F'; }
		elsif($codon eq 'UUC') { $aa .= 'F'; }
		elsif($codon eq 'UUA') { $aa .= 'L'; }
		elsif($codon eq 'UUG') { $aa .= 'L'; }
		elsif($codon eq 'CUU') { $aa .= 'L'; }
		elsif($codon eq 'CUC') { $aa .= 'L'; }
		elsif($codon eq 'CUA') { $aa .= 'L'; }
		elsif($codon eq 'CUG') { $aa .= 'L'; }
		elsif($codon eq 'AUU') { $aa .= 'I'; }
		elsif($codon eq 'AUC') { $aa .= 'I'; }
		elsif($codon eq 'AUA') { $aa .= 'I'; }
		elsif($codon eq 'AUG') { $aa .= 'M'; }
		elsif($codon eq 'GUU') { $aa .= 'V'; }
		elsif($codon eq 'GUC') { $aa .= 'V'; }
		elsif($codon eq 'GUA') { $aa .= 'V'; }
		elsif($codon eq 'GUG') { $aa .= 'V'; }
		elsif($codon eq 'UCU') { $aa .= 'S'; }
		elsif($codon eq 'UCC') { $aa .= 'S'; }
		elsif($codon eq 'UCA') { $aa .= 'S'; }
		elsif($codon eq 'UCG') { $aa .= 'S'; }
		elsif($codon eq 'CCU') { $aa .= 'P'; }
		elsif($codon eq 'CCC') { $aa .= 'P'; }
		elsif($codon eq 'CCA') { $aa .= 'P'; }
		elsif($codon eq 'CCG') { $aa .= 'P'; }
		elsif($codon eq 'ACU') { $aa .= 'T'; }
		elsif($codon eq 'ACC') { $aa .= 'T'; }
		elsif($codon eq 'ACA') { $aa .= 'T'; }
		elsif($codon eq 'ACG') { $aa .= 'T'; }
		elsif($codon eq 'GCU') { $aa .= 'A'; }
		elsif($codon eq 'GCC') { $aa .= 'A'; }
		elsif($codon eq 'GCA') { $aa .= 'A'; }
		elsif($codon eq 'GCG') { $aa .= 'A'; }
		elsif($codon eq 'UAU') { $aa .= 'Y'; }
		elsif($codon eq 'UAC') { $aa .= 'Y'; }
		elsif($codon eq 'UAA') { last; }
		elsif($codon eq 'UAG') { last; }
		elsif($codon eq 'CAU') { $aa .= 'H'; }
		elsif($codon eq 'CAC') { $aa .= 'H'; }
		elsif($codon eq 'CAA') { $aa .= 'Q'; }
		elsif($codon eq 'CAG') { $aa .= 'Q'; }
		elsif($codon eq 'AAU') { $aa .= 'N'; }
		elsif($codon eq 'AAC') { $aa .= 'N'; }
		elsif($codon eq 'AAA') { $aa .= 'K'; }
		elsif($codon eq 'AAG') { $aa .= 'K'; }
		elsif($codon eq 'GAU') { $aa .= 'D'; }
		elsif($codon eq 'GAC') { $aa .= 'D'; }
		elsif($codon eq 'GAA') { $aa .= 'E'; }
		elsif($codon eq 'GAG') { $aa .= 'E'; }
		elsif($codon eq 'UGU') { $aa .= 'C'; }
		elsif($codon eq 'UGC') { $aa .= 'C'; }
		elsif($codon eq 'UGA') { last; }
		elsif($codon eq 'UGG') { $aa .= 'W'; }
		elsif($codon eq 'CGU') { $aa .= 'R'; }
		elsif($codon eq 'CGC') { $aa .= 'R'; }
		elsif($codon eq 'CGA') { $aa .= 'R'; }
		elsif($codon eq 'CGG') { $aa .= 'R'; }
		elsif($codon eq 'AGU') { $aa .= 'S'; }
		elsif($codon eq 'AGC') { $aa .= 'S'; }
		elsif($codon eq 'AGA') { $aa .= 'R'; }
		elsif($codon eq 'AGG') { $aa .= 'R'; }
		elsif($codon eq 'GGU') { $aa .= 'G'; }
		elsif($codon eq 'GGC') { $aa .= 'G'; }
		elsif($codon eq 'GGA') { $aa .= 'G'; }
		elsif($codon eq 'GGG') { $aa .= 'G'; }
		$i += 3;
	}
	return $aa;
}

# Auxiliar subprocedures
sub _calculate_genotype {
	my ($inheritance, $sex, $genotype) = @_;
	my $out = {};
	if(($inheritance eq 'autosomic dominant')||($inheritance eq 'autosomic recessive')) {
		$out->{$sex} = substr($genotype->{'M'}, random(0, 1), 1) . substr($genotype->{'F'}, random(0, 1), 1);
		$out->{_sex_not($sex)} = (random(0, 1) == 0 ? 'X' : 'x') . 'x';
	}
	if($inheritance eq 'x-linked') {
		if($sex eq 'M') {
			$out->{'M'} = substr($genotype->{'F'}, random(0, 1), 1);
			$out->{'F'} = 'Xx';
		} elsif($sex eq 'F') {
			$out->{'F'} = substr($genotype->{'F'}, random(0, 1), 1) . $genotype->{'M'};
			$out->{'M'} = (random(0, 1) == 0 ? 'X' : 'x') . 'x';
		}
	}
	if($inheritance eq 'y-linked') {
		if($sex eq 'M') {
			$out->{'M'} = $genotype->{'M'};
			$out->{'M'} =~ s/X//;
			$out->{'M'} = 'X' . $out->{'M'};
		} elsif($sex eq 'F') {
			$out->{'M'} = 'X' . (random(0, 1) == 0 ? 'Y' : 'y');
		}
	}
	if($inheritance eq 'mitochondrial') {
		if($genotype->{'F'} =~ m/X/) {
			$out->{'M'} = 'X';
			$out->{'F'} = 'X';
		} else {
			$out->{'M'} = 'x';
			$out->{'F'} = (random(0, 1) == 0 ? 'X' : 'x');
		}
	}
	return $out;
}
sub _calculate_phenotype {
	my ($inheritance, $sex, $genotype) = @_;
	if($inheritance eq 'autosomic dominant') { if(defined $genotype->{$sex}) { if($genotype->{$sex} =~ m/X/) { return 1; } } }
	if($inheritance eq 'autosomic recessive') { if(defined $genotype->{$sex}) { if($genotype->{$sex} =~ m/xx/) { return 1; } } }
	if($inheritance eq 'x-linked') { if($sex eq 'F') { if(defined $genotype->{'F'}) { if($genotype->{'F'} =~ m/XX/) { return 1; } } } }
	if($inheritance eq 'y-linked') { if($sex eq 'M') { if(defined $genotype->{'M'}) { if($genotype->{'M'} =~ m/Y/) { return 1; } } } }
	if($inheritance eq 'mitochondrial') { if(defined $genotype->{$sex}) { if($genotype->{$sex} =~ m/X/) { return 1; } } }
	return 0;
}
sub _sex_not {
	my ($sex) = @_;
	if($sex eq 'M') { return 'F'; }
	elsif($sex eq 'F') { return 'M'; }
}
sub _p_wrap {
	my ($s) = @_;
	my @a = ();

	while($s =~ m/\(([^())]+?)\)/) {
		my $m = $1;
		my $sa = scalar @a;
		$s =~ s/\($m\)/<__$sa\/>/g;
		$a[$sa] = $m;
	}
	return ($s, @a);
}
sub _p_unwrap_once {
	my ($s, @a) = @_;

	my @m = $s =~ m/<__(\d+)\/>/g;
	my $i = 0;
	for(;$i<scalar @m;++$i) {
		my $mi = $m[$i];
		my $ss = $a[$mi];
		$s =~ s/<__$mi\/>/$ss/g;
	}
	return $s;
}
sub _parse_pedigree_string {
	my ($s) = @_;

	my ($a, @b) = _p_wrap($s);
	$a = _p_unwrap_once($a, @b);

	my ($na, $nw, $nh) = _parse_pedigree_node($a, 0, @b);
	return $na;
}
sub _parse_pedigree_node {
	my ($a, $b, @c) = @_;

	my $node = {};
	my $w = 0;
	my $h = 20;
	my @sp = split(/,/, $a);
	if(@sp > 0) {
		$node->{'l'} = $sp[0];
		$w = 20;
	}
	if(@sp > 1) {
		$node->{'r'} = $sp[1];
		$w = 60;
	}
	if(@sp > 2) {
		my ($ca, $cw, $ch) = _parse_pedigree_childs(_p_unwrap_once($sp[2], @c), @c);
		$node->{'c'} = $ca;
		if($cw > $w) { $w = $cw; }
		$h += $ch;
	}
	$node->{'x'} = $b;
	$node->{'w'} = $w;
	$node->{'h'} = $h;
	return ($node, $w, $h);
}
sub _parse_pedigree_childs {
	my ($a, @b) = @_;

	my $c = [];
	my $w = 0;
	my $h = 0;
	my @sp = split(/,/, $a);
	my $i = 0;
	for(;$i<scalar @sp;++$i) {
		my ($na, $nw, $nh) = _parse_pedigree_node(_p_unwrap_once($sp[$i], @b), ($w == 0 ? $w : $w+20), @b);
		$c->[$i] = $na;
		$w += ($w == 0 ? 0 : 20) + $nw;
		if($nh > $h) { $h = $nh; }
	}
	return ($c , $w, $h+20);
}
sub _div {
	my (%div) = @_;
	if(!exists $div{'bg'}) { $div{'bg'} = '#000'; }
	if(!exists $div{'x'}) { $div{'x'} = 0; }
	if(!exists $div{'y'}) { $div{'y'} = 0; }
	if(!exists $div{'w'}) { $div{'w'} = 20; }
	if(!exists $div{'h'}) { $div{'h'} = 20; }
	if(!exists $div{'style'}) { $div{'style'} = ''; }
	if(!exists $div{'html'}) { $div{'html'} = ''; }

	my $s = '<div style="background-color: ' . $div{'bg'} . '; height: ' . $div{'h'} . 'px; left: ' . $div{'x'} . 'px; position: absolute; top: ' . $div{'y'} . 'px; text-align: center; width: ' . $div{'w'} . 'px;' . ($div{'style'} eq '' ? '' : ' ' . $div{'style'}) . '">' . $div{'html'} . '</div>';
	return $s;
}
sub _render_pedigree_tree {
	my ($node, $siblings) = @_;
	if(!exists $node->{'x'}) { $node->{'x'} = 0; }
	if(!exists $node->{'y'}) { $node->{'y'} = 0; }
	if(!exists $node->{'w'}) { $node->{'w'} = 0; }
	if(!exists $node->{'h'}) { $node->{'h'} = 0; }
	if(!exists $node->{'lt'}) { $node->{'lt'} = ''; }
	if(!exists $node->{'rt'}) { $node->{'rt'} = ''; }

	my $html = '';
	if(exists $node->{'l'}) {
		if(substr($node->{'l'}, 1, 1) =~ m/\d/) { $node->{'lt'} = substr($node->{'l'}, 1, 1); }
		$html = _div(('bg' => (substr($node->{'l'}, 1, 1) eq 'X' ? '#000' : (substr($node->{'l'}, 0, 1) eq 'M' ? 'hsl(240, 100%, 99%)' : 'hsl(0, 100%, 99%)')), 'x' => ($node->{'w'}-20)/2-(exists $node->{'r'} ? 20 : 0), 'style' => 'border: 1px solid black;' . (substr($node->{'l'}, 0, 1) eq 'M' ? '' : ' border-radius: 50%;'), 'html' => $node->{'lt'}));
	}
	if(exists $node->{'r'}) {
		if(substr($node->{'r'}, 1, 1) =~ m/\d/) { $node->{'rt'} = substr($node->{'r'}, 1, 1); }
		$html .= _div(('bg' => (substr($node->{'r'}, 1, 1) eq 'X' ? '#000' : (substr($node->{'r'}, 0, 1) eq 'M' ? 'hsl(240, 100%, 99%)' : 'hsl(0, 100%, 99%)')), 'x' => ($node->{'w'}-20)/2+20, 'style' => 'border: 1px solid black;' . (substr($node->{'r'}, 0, 1) eq 'M' ? '' : ' border-radius: 50%;'), 'html' => $node->{'rt'}));
		$html .= _div(('bg' => '#000', 'x' => (($node->{'w'}-20)/2)+1,  'y' => (20/2),  'w' => 19,  'h' => 1));
	}
	$html .= _div(('bg' => '#000', 'x' => $node->{'w'}/2-(exists $node->{'r'} ? 20 : 0),  'y' => -20/2,  'w' => 1,  'h' => 20/2));
	if($siblings == 1) { $html .= _div(('bg' => '#000', 'x' => $node->{'w'}/2-(exists $node->{'r'} ? 20 : 0),  'y' => -20/2,  'w' => 21,  'h' => 1)); }
	if(exists $node->{'c'}) {
		my $i = 0;
		for(;$i<scalar @{$node->{'c'}};++$i) {
			if(!exists $node->{'c'}[$i]{'y'}) { $node->{'c'}[$i]{'y'} = 40; }
			$html .= _render_pedigree_tree($node->{'c'}[$i], scalar @{$node->{'c'}});
		}
		$html .= _div(('bg' => '#000', 'x' => $node->{'w'}/2,  'y' => 20/2,  'w' => 1,  'h' => 20));
		my $cx = ($node->{'c'}[0]{'w'}/2)+$node->{'c'}[0]{'x'}-(exists $node->{'c'}[0]{'r'} ? 20 : 0);
		my $cw = ($node->{'c'}[(scalar @{$node->{'c'}})-1]{'w'}/2)+$node->{'c'}[(scalar @{$node->{'c'}})-1]{'x'}-(exists $node->{'c'}[(scalar @{$node->{'c'}})-1]{'r'} ? 20 : 0)-$cx;
		$html .= _div(('bg' => '#000', 'x' => $cx,  'y' => 20+(20/2),  'w' => $cw,  'h' => 1));
	}

	my $s = _div(('bg' => 'rgba(255, 255, 0, 0)', 'x' => $node->{'x'},  'y' => $node->{'y'}, 'w' => $node->{'w'}, 'h' => $node->{'h'}, 'html' => $html));
	return $s;
}
