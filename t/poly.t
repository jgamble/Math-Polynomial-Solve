# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(poly_roots);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/format.pl";
my($a, $b, $c, $d, $e);

my @x = poly_roots(1,4,6,4,1);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 4) == 0 and fltcmp($e, 1) == 0);
print "ok 2\n";
#rootprint(@x);

@x = poly_roots(0,1,3,3,1);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, 3) == 0 and fltcmp($d, -1) == 0);
print "ok 3\n";
#rootprint(@x);

@x = poly_roots(0,0,1,2,1);
$b = -$x[0] - $x[1];
$c = $x[0] * $x[1];
print "not " unless (fltcmp($b, 2) == 0 and fltcmp($c, 1) == 0);
print "ok 4\n";
#rootprint(@x);

@x = poly_roots(3,6,-1,-4,2);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 2) == 0 and fltcmp($e, 2/3) == 0);
print "ok 5\n";
#rootprint(@x);

1;
