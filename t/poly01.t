# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(poly_roots set_hessenberg);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/complex.pl";
require "t/coef.pl";

set_hessenberg(1);

#
# Identical to poly00.t, except for the next line that sets the
# 'always use the iterative matrix' flag.
#
$Math::Polynomial::Solve::use_hessenberg = 1;

my @x = poly_roots(1,4,6,4,1);
my $cn_1 = -$x[0] - $x[1] - $x[2] - $x[3];
my $c0 = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($cn_1, 4) == 0 and fltcmp($c0, 1) == 0);
print "ok 2\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(0,1,3,3,1);
$cn_1 = -$x[0] - $x[1] - $x[2];
$c0 = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($cn_1, 3) == 0 and fltcmp($c0, -1) == 0);
print "ok 3\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(0,0,1,2,1);
$cn_1 = -$x[0] - $x[1];
$c0 = $x[0] * $x[1];
print "not " unless (fltcmp($cn_1, 2) == 0 and fltcmp($c0, 1) == 0);
print "ok 4\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(3,6,-1,-4,2);
$cn_1 = -$x[0] - $x[1] - $x[2] - $x[3];
$c0 = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($cn_1, 2) == 0 and fltcmp($c0, 2/3) == 0);
print "ok 5\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(-3,-6,1,4,-2);
$cn_1 = -$x[0] - $x[1] - $x[2] - $x[3];
$c0 = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($cn_1, 2) == 0 and fltcmp($c0, 2/3) == 0);
print "ok 6\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1,0,-30,0,289);
$cn_1 = -$x[0] - $x[1] - $x[2] - $x[3];
$c0 = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($cn_1, 0) == 0 and fltcmp($c0, 289) == 0);
print "ok 7\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1,0,-30,0,289, 0, 0, 0);
$cn_1 = -$x[0] - $x[1] - $x[2] - $x[3] - $x[4] - $x[5] - $x[6];
$c0 = $x[0] * $x[1] * $x[2] * $x[3] * $x[4] * $x[5] * $x[6];
print "not " unless (fltcmp($cn_1, 0) == 0 and fltcmp($c0, 0) == 0);
print "ok 8\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(2, 1);
$c0 = $x[0];
print "not " unless (fltcmp($c0, -0.5) == 0);
print "ok 9\n";
#rootprint(@x);
#print "\tc0 = $c0\n";

1;
