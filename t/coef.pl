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
	my($flt) = 0.5/16777216;	# a good enough value for testing.

	return -1 if ($a + $flt < $b);
	return 1 if ($a - $flt > $b);
	return 0;
}
1;
