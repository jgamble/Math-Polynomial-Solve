# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(cubic_roots);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/complex.pl";
require "t/coef.pl";

my @x = cubic_roots(1,3,3,1);
my $b = -$x[0] - $x[1] - $x[2];
my $d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, 3) == 0 and fltcmp($d, -1) == 0);
print "ok 2\n";
#rootprint(@x);

@x = cubic_roots(1,0,0,-1);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($d, 1) == 0);
print "ok 3\n";
#rootprint(@x);

@x = cubic_roots(1,0,0,1);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($d, -1) == 0);
print "ok 4\n";
#rootprint(@x);

@x = cubic_roots(1,-6,11,-6);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, -6) == 0 and fltcmp($d, 6) == 0);
print "ok 5\n";
#rootprint(@x);

@x = cubic_roots(1,-13,59,-87);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, -13) == 0 and fltcmp($d, 87) == 0);
print "ok 6\n";
#rootprint(@x);

@x = cubic_roots(1,5,-62,-336);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, 5) == 0 and fltcmp($d, 336) == 0);
print "ok 7\n";
#rootprint(@x);

@x = cubic_roots(1,-4,4,-16);
$b = -$x[0] - $x[1] - $x[2];
$d = $x[0] * $x[1] * $x[2];
print "not " unless (fltcmp($b, -4) == 0 and fltcmp($d, 16) == 0);
print "ok 8\n";
#rootprint(@x);

1;
