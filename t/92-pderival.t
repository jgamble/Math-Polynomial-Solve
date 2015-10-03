# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl pderival.t'

use Test::Simple tests => 20;

use Math::Polynomial::Solve qw(poly_derivaluate fltcmp ascending_order);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my(@coef, $y, $dy, $d2y);

#
# (1, 0, 0, 0, -1)
#
# At point 5.
#
@coef = (1, 0, 0, 0, -1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 624) == 0 and
	fltcmp($dy, 500) == 0 and
	fltcmp($d2y, 300) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (1, 4, 6, 4, 1)
#
# At point 5.
#
@coef = (1, 4, 6, 4, 1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 1296) == 0 and
	fltcmp($dy, 864) == 0 and
	fltcmp($d2y, 432) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (1, -10, 35, -50, 24)
#
# At point 5.
#
@coef = (1, -10, 35, -50, 24);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 24) == 0 and
	fltcmp($dy, 50) == 0 and
	fltcmp($d2y, 70) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (-31, 14, -16, -14, 1)
#
# At point 5
#
@coef = (-31, 14, -16, -14, 1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, -18094) == 0 and
	fltcmp($dy, -14624) == 0 and
	fltcmp($d2y, -8912) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (4, -20, -7, 49, -70, 7, -53, 90)
#
# At points 5, 3, 1, -1, -3, -5
#
@coef = (4, -20, -7, 49, -70, 7, -53, 90);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 0) == 0 and
	fltcmp($dy, 59892) == 0 and
	fltcmp($d2y, 145114) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, 3);

ok( (fltcmp($y, -5460) == 0 and
	fltcmp($dy, -8192) == 0 and
	fltcmp($d2y, -7510) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, 1);

ok( (fltcmp($y, 0) == 0 and
	fltcmp($dy, -180) == 0 and
	fltcmp($d2y, -390) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -1);

ok( (fltcmp($y, 252) == 0 and
	fltcmp($dy, -360) == 0 and
	fltcmp($d2y, 394) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -3);

ok( (fltcmp($y, -15456) == 0 and
	fltcmp($dy, 39460) == 0 and
	fltcmp($d2y, -79078) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -5);

ok( (fltcmp($y, -563220) == 0 and
	fltcmp($dy, 760752) == 0 and
	fltcmp($d2y, -865686) == 0),
	"   [ " . join(", ", @coef) . " ]");

ascending_order(1);

#
# (1, 0, 0, 0, -1)
#
# At point 5.
#
@coef = reverse(1, 0, 0, 0, -1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 624) == 0 and
	fltcmp($dy, 500) == 0 and
	fltcmp($d2y, 300) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (1, 4, 6, 4, 1)
#
# At point 5.
#
@coef = reverse(1, 4, 6, 4, 1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 1296) == 0 and
	fltcmp($dy, 864) == 0 and
	fltcmp($d2y, 432) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (1, -10, 35, -50, 24)
#
# At point 5.
#
@coef = reverse(1, -10, 35, -50, 24);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 24) == 0 and
	fltcmp($dy, 50) == 0 and
	fltcmp($d2y, 70) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (-31, 14, -16, -14, 1)
#
# At point 5
#
@coef = reverse(-31, 14, -16, -14, 1);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, -18094) == 0 and
	fltcmp($dy, -14624) == 0 and
	fltcmp($d2y, -8912) == 0),
	"   [ " . join(", ", @coef) . " ]");

#
# (4, -20, -7, 49, -70, 7, -53, 90)
#
# At points 5, 3, 1, -1, -3, -5
#
@coef = reverse(4, -20, -7, 49, -70, 7, -53, 90);

($y, $dy, $d2y) = poly_derivaluate(\@coef, 5);

ok( (fltcmp($y, 0) == 0 and
	fltcmp($dy, 59892) == 0 and
	fltcmp($d2y, 145114) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, 3);

ok( (fltcmp($y, -5460) == 0 and
	fltcmp($dy, -8192) == 0 and
	fltcmp($d2y, -7510) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, 1);

ok( (fltcmp($y, 0) == 0 and
	fltcmp($dy, -180) == 0 and
	fltcmp($d2y, -390) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -1);

ok( (fltcmp($y, 252) == 0 and
	fltcmp($dy, -360) == 0 and
	fltcmp($d2y, 394) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -3);

ok( (fltcmp($y, -15456) == 0 and
	fltcmp($dy, 39460) == 0 and
	fltcmp($d2y, -79078) == 0),
	"   [ " . join(", ", @coef) . " ]");

($y, $dy, $d2y) = poly_derivaluate(\@coef, -5);

ok( (fltcmp($y, -563220) == 0 and
	fltcmp($dy, 760752) == 0 and
	fltcmp($d2y, -865686) == 0),
	"   [ " . join(", ", @coef) . " ]");

1;
