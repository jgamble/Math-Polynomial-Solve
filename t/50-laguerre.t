# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl laguerre.t'

use Test::Simple tests => 8;

use Math::Polynomial::Solve qw(laguerre ascending_order);
use Math::Utils qw(:compare);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my $fltcmp = generate_fltcmp();

ascending_order(1);

ok_laguerre([-12, -11, 2, 1], [-4.5, 0.5, 2.5]);
ok_laguerre([-1, -2, 11, 12], [-0.5, 0.3, -5]);
ok_laguerre([11, 10, 8, 5, 1], [-8, 8]);
exit(0);

sub ok_laguerre
{
	my($c_ref, $est_ref) = @_;
	my @coef = @$c_ref;
	my @x = laguerre($c_ref, $est_ref);

	#rootprint(@x);

	foreach my $xv (@x)
	{
		my $yv = pl_evaluate($c_ref, $xv);
		ok( (&$fltcmp($yv, 0.0) == 0),
		"   [ " . join(", ", @coef) . " ], root == $xv");
	}
}

1;
