use Math::Complex;

sub fltcmp
{
	my($a, $b) = @_;
	my($flt) = 1.0/16777216;	# a good enough value for testing.

	return -1 if ($a + $flt < $b);
	return 1 if ($a - $flt > $b);
	return 0;
}

sub rootprint
{
	my $i = 0;
	my $line = "";
	foreach (@_)
	{
		$line .= "\tx[$i] = $_\n";
		$i++;
	}
	print STDERR "\n", $line;
}
1;
