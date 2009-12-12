# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(poly_roots);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/complex.pl";
require "t/coef.pl";

my @x = poly_roots(1,0,0,0,0,-1);
my $cn_1 = -sumof(@x);
my $c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 0) == 0 and fltcmp($c0, 1) == 0);
print "ok 2\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1,5,10,10,5,1);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 5) == 0 and fltcmp($c0, -1) == 0);
print "ok 3\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1,1,1,1,1,1,1,1);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 1) == 0 and fltcmp($c0, -1) == 0);
print "ok 4\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1,0,-3,-4,3,6,2);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 0) == 0 and fltcmp($c0, 2) == 0);
print "ok 5\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(-1,0,3,4,-3,-6,-2);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 0) == 0 and fltcmp($c0, 2) == 0);
print "ok 6\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

#
# (4x**2 - 8x + 9)(x + 2)(x - 5)(x**3 - 1)
#
@x = poly_roots(4,-20,-7,49,-70,7,-53,90);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, -5) == 0 and fltcmp($c0, -22.5) == 0);
print "ok 7\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

@x = poly_roots(1950773, 7551423, -1682934, 137445, -4961, 67);
$cn_1 = -sumof(@x);
$c0 = prodof(@x);
print "not " unless (fltcmp($cn_1, 7551423/1950773) == 0 and fltcmp($c0, -67/1950773) == 0);
print "ok 8\n";
#rootprint(@x);
#print "\tcn_1 = $cn_1, c0 = $c0\n";

1;
