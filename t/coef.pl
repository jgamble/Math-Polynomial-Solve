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

sub fltcmp
{
	my($a, $b) = @_;
	my($flt) = 0.25/16777216;	# a good enough value for testing.

	return -1 if ($a + $flt < $b);
	return 1 if ($a - $flt > $b);
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
