# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial::Solve qw(quartic_roots);
use Math::Complex;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require "t/format.pl";

my @x = quartic_roots(1,4,6,4,1);
my $b = -$x[0] - $x[1] - $x[2] - $x[3];
my $e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 4) == 0 and fltcmp($e, 1) == 0);
print "ok 2\n";
#rootprint(@x);

@x = quartic_roots(1,0,0,0,-1);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($e, -1) == 0);
print "ok 3\n";
#rootprint(@x);

@x = quartic_roots(1,0,0,0,1);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 0) == 0 and fltcmp($e, 1) == 0);
print "ok 4\n";
#rootprint(@x);

@x = quartic_roots(1,-10,35,-50,24);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, -10) == 0 and fltcmp($e, 24) == 0);
print "ok 5\n";
#rootprint(@x);

@x = quartic_roots(1,6,-5,-10,-3);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 6) == 0 and fltcmp($e, -3) == 0);
print "ok 6\n";
#rootprint(@x);

@x = quartic_roots(1,6,7,-7,-12);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 6) == 0 and fltcmp($e, -12) == 0);
print "ok 7\n";
#rootprint(@x);

@x = quartic_roots(1,6,-1,4, 2);
$b = -$x[0] - $x[1] - $x[2] - $x[3];
$e = $x[0] * $x[1] * $x[2] * $x[3];
print "not " unless (fltcmp($b, 6) == 0 and fltcmp($e, 2) == 0);
print "ok 8\n";
#rootprint(@x);

1;
