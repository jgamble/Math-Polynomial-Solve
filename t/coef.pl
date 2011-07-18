use Math::Complex;

sub sumof
{
	my $x = cplx(0,0);
	foreach (@_){$x += $_};
	return $x;
}

sub prodof
{
	my $x = cplx(1,0);
	foreach (@_){$x *= $_};
	return $x;
}

#
# returns 0 (equal) or 1 (not equal). There's no -1 value, unlike other cmp functions.
#
sub polycmp
{
	my($p_ref1, $p_ref2) = @_;

	my @polynomial1 = @$p_ref1;
	my @polynomial2 = @$p_ref2;

	return 1 if (scalar @polynomial1 != scalar @polynomial2);

	foreach my $c1 (@polynomial1)
	{
		my $c2 = shift @polynomial2;
		return 1 if (fltcmp($c1, $c2) != 0);
	}

	return 0;
}

sub cartesian_format_signed($$@)
{
	my($fmt_re, $fmt_im, @numbers) = @_;
	my(@cfn, $n, $r, $i, $s);

	$fmt_re ||= "%.15g";	# Provide a default real format
	$fmt_im ||= "%.15gi";	# Provide a default im format

	foreach $n (@numbers)
	{
		#
		# Is the number part of the Complex package?
		#
		if (ref($n) eq "Math::Complex")
		{
			$r = sprintf($fmt_re, Re($n));
			$i = sprintf($fmt_im, abs(Im($n)));
			$s = ('+', '+', '-')[Im($n) <=> 0];
		}
		else
		{
			$r = sprintf($fmt_re, $n);
			$i = sprintf($fmt_im, 0);
			$s = '+';
		}

		push @cfn, $r . $s . $i;
	}

	return wantarray? @cfn: $cfn[0];
}

sub cartesian_format($$@)
{
	my($fmt_re, $fmt_im, @numbers) = @_;
	my(@cfn, $n, $r, $i);

	$fmt_re ||= "%.15g";		# Provide a default real format
	$fmt_im ||= " + %.15gi";	# Provide a default im format

	foreach $n (@numbers)
	{
		#
		# Is the number part of the Complex package?
		#
		if (ref($n) eq "Math::Complex")
		{
			$r = sprintf($fmt_re, Re($n));
			$i = sprintf($fmt_im, Im($n));
		}
		else
		{
			$r = sprintf($fmt_re, $n);
			$i = sprintf($fmt_im, 0);
		}

		push @cfn, $r . $i;
	}

	return wantarray? @cfn: $cfn[0];
}

sub rootprint
{
	my $i = 0;
	my $line = "";
	foreach (@_)
	{
		$line .= "\tx[$i] = " . cartesian_format(undef, undef, $_) . "\n";
		$i++;
	}
	print STDERR "\n", $line;
}

sub rootformat
{
	my @fmtlist;
	foreach (@_)
	{
		push @fmtlist, cartesian_format(undef, undef, $_);
	}
	return "[ " . join(", ", @fmtlist) . " ]";
}

1;
