# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(quadratic_roots);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/complex.pl";
require "t/coef.pl";

my @x = quadratic_roots(1,2,1);
my $b = -$x[0] - $x[1];
my $c = $x[0] * $x[1];
print "not " unless (fltcmp($b, 2) == 0 and fltcmp($c, 1) == 0);
print "ok 2\n";
#rootprint(@x);

@x = quadratic_roots(1,0,-1);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($c, -1) == 0);
print "ok 3\n";
#rootprint(@x);

@x = quadratic_roots(1,0,1);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($c, 1) == 0);
print "ok 4\n";
#rootprint(@x);

@x = quadratic_roots(1,-3,2);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, -3) == 0 and fltcmp($c, 2) == 0);
print "ok 5\n";
#rootprint(@x);

@x = quadratic_roots(1,11,-6);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, 11) == 0 and fltcmp($c, -6) == 0);
print "ok 6\n";
#rootprint(@x);

@x = quadratic_roots(1,-7,12);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, -7) == 0 and fltcmp($c, 12) == 0);
print "ok 7\n";
#rootprint(@x);

@x = quadratic_roots(1,-13,12);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, -13) == 0 and fltcmp($c, 12) == 0);
print "ok 8\n";
#rootprint(@x);

1;
