package Math::Polynomial::Solve;

require 5.004_04;

use Math::Complex;
use Carp;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION $epsilon);
use strict;

@ISA = qw(Exporter);

#
# Export only on request.
#
@EXPORT_OK = qw(
	poly_roots
	linear_roots
	quadratic_roots
	cubic_roots
	quartic_roots
);

$VERSION = '1.00';

#
# Set up the epsilon variable, the value that in the floating-point math
# of the computer is the smallest value a variable can have before it is
# indistinguishable from zero when adding it to one.
#

BEGIN
{
	my $epsilon2 = 0.25;
	$epsilon = 0.5;

	while (1.0 + $epsilon2 > 1.0)
	{
		$epsilon = $epsilon2;
		$epsilon2 /= 2.0;
	}

#	print "\$Math::Polynomial::Solve::epsilon = ", $epsilon, "\n";
}

#
# @x = linear_roots($a, $b)
#
#
sub linear_roots(@)
{
	my($a, $b) = @_;

	if (abs($a) <= $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return (undef);
	}

	return wantarray? (-$b/$a): -$b/$a;
}

#
# @x = quadratic_roots($a, $b, $c)
#
#
sub quadratic_roots(@)
{
	my($a, $b, $c) = @_;

	if (abs($a) <= $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return (undef, undef);
	}

	return (0, -$b/$a) if (abs($c) < $epsilon);

	my $dis_sqrt = sqrt($b*$b - $a * 4 * $c);

	$dis_sqrt = -$dis_sqrt if ($b < 0);	# Avoid catastrophic cancellation.

	my $xt = ($b + $dis_sqrt)/-2;

	return ($xt/$a, $c/$xt);
}

#
# @x = cubic_roots($a, $b, $c, $d)
#
#
sub cubic_roots(@)
{
	my($a, $b, $c, $d) = @_;
	my @x;

	if (abs($a) <= $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return @x;
	}

	return (0, quadratic_roots($a, $b, $c)) if (abs($d) < $epsilon);

	my $xN = -$b/3/$a;
	my $yN = $d + $xN * ($c + $xN * ($b + $a * $xN));

	my $two_a = 2 * $a;
	my $delta_sq = ($b * $b - 3 * $a * $c)/(9 * $a * $a);
	my $h_sq = $two_a * $two_a * $delta_sq**3;
	my $dis = $yN * $yN - $h_sq;
	my $twothirds_pi = (2 * pi)/3;

	if ($dis >= $epsilon)
	{
		#
		# One real root, two complex roots.
		#
		my $dis_sqrt = sqrt($dis);
		my $r_p = $yN - $dis_sqrt;
		my $r_q = $yN + $dis_sqrt;
		my $p = cbrt( abs($r_p)/$two_a );
		my $q = cbrt( abs($r_q)/$two_a );

		$p = -$p if ($r_p > 0);
		$q = -$q if ($r_q > 0);

		$x[0] = $xN + $p + $q;
		$x[1] = $xN + $p * exp($twothirds_pi * i)
			    + $q * exp(-$twothirds_pi * i);
		$x[2] = ~$x[1];
	}
	elsif ($dis < -$epsilon)
	{
		#
		# Three distinct real roots.
		#
		my $theta = acos(-$yN/sqrt($h_sq))/3;
		my $delta = sqrt($delta_sq);
		my $two_d = 2 * $delta;

		@x = ($xN + $two_d * cos($theta),
			$xN + $two_d * cos($twothirds_pi - $theta),
			$xN + $two_d * cos($twothirds_pi + $theta));
	}
	else
	{
		#
		# abs($dis) <= $epsilon (effectively zero).
		#
		# Three real roots (two or three equal).
		#
		my $delta = cbrt($yN/$two_a);

		@x = ($xN + $delta, $xN + $delta, $xN - 2 * $delta);
	}

	return @x;
}

#
# @x = quartic_roots($a, $b, $c, $d, $e)
#
#
sub quartic_roots(@)
{
	my($a,$b,$c,$d,$e) = @_;
	my @x = ();

	if (abs($a) < $epsilon)
	{
		carp "Coefficient of highest power must not be zero!\n";
		return @x;
	}

	return (0, cubic_roots($a, $b, $c, $d)) if (abs($e) < $epsilon);

	#
	# First step:  Divide by the leading coefficient.
	#
	$b /= $a;
	$c /= $a;
	$d /= $a;
	$e /= $a;

	#
	# Second step: simplify the equation to the
	# "resolvant cubic"  y**4 + fy**2 + gy + h.
	#
	# (This is done by setting x = y - b/4).
	#

	my $b4 = $b/4;

	#
	# The f, g, and h values are:
	#
	my $f = $c -
		6 * $b4 * $b4;
	my $g = $d +
		2 * $b4 * (-$c + 4 * $b4 * $b4);
	my $h = $e +
		$b4 * (-$d + $b4 * ($c - 3 * $b4 * $b4));


	if (abs($h) < $epsilon)
	{
		#
		# Special case: h == 0.  We have a cubic times y.
		#
		@x = (0, cubic_roots(1, 0, $f, $g));
	}
	elsif (abs($g) < $epsilon)
	{
		#
		# Another special case: g == 0.  We have a quadratic
		# with y-squared.
		#
		my($p, $q) = quadratic_roots(1, $f, $h);
		$p = sqrt($p);
		$q = sqrt($q);
		@x = ($p, -$p, $q, -$q);
	}
	else
	{
		#
		# Special cases don't apply, so continue on with Ferrari's
		# method.  This involves setting up the resolvant cubic
		# as the product of two quadratics.
		#
		# After setting up conditions that guarantee that the
		# coefficients come out right (including the zero value
		# for the third-power term), we wind up with a 6th
		# degree polynomial with, fortunately, only even-powered
		# terms.  In other words, a cubic with z = y**2.
		#
		# Take a root of that equation, and get the
		# quadratics from it.
		#
		my($z);
		($z, undef, undef) = cubic_roots(1, 2*$f, $f*$f - 4*$h, -$g*$g);
#		print STDERR "\n\tz = $z\n";
		my $alpha = sqrt($z);
		my $rho = $g/$alpha;
		my $beta = ($f + $z - $rho)/2;
		my $gamma = ($f + $z + $rho)/2;

		@x = quadratic_roots(1, $alpha, $beta);
		push @x, quadratic_roots(1, -$alpha, $gamma);
	}

	return ($x[0] - $b4, $x[1] - $b4, $x[2] - $b4, $x[3] - $b4);
}

#
# @x = poly_roots(@coefficients)
#
#
sub poly_roots
{
	my(@coefficients) = @_;
	my(@x) = ();

	#
	# Check for zero coefficients in the higher-powered terms.
	#
	shift @coefficients while (@coefficients and $coefficients[0] <= $epsilon);

	if (@coefficients == 0)
	{
		carp "All coefficients are zero\n";
		return @x;
	}

	#
	# How about zero coefficients in the low terms?
	#
	while (@coefficients and $coefficients[$#coefficients] <= $epsilon)
	{
		push @x, 0;
		pop @coefficients;
	}

	if ($#coefficients > 4 or $#coefficients < 1)
	{
		carp "Cannot find the roots of polynomials of degree 5 or higher\n";
	}
	elsif ($#coefficients == 4)
	{
		push @x, quartic_roots(@coefficients);
	}
	elsif ($#coefficients == 3)
	{
		push @x, cubic_roots(@coefficients);
	}
	elsif ($#coefficients == 2)
	{
		push @x, quadratic_roots(@coefficients);
	}
	elsif ($#coefficients == 1)
	{
		push @x, linear_roots(@coefficients);
	}

	return @x;
}

1;
__END__

=head1 NAME

Math::Polynomial::Solve - Find the roots of polynomial equations.

=head1 SYNOPSIS

  use Math::Complex;  # The roots may be complex numbers.
  use Math::Polynomial::Solve qw(poly_roots);

  my @x = poly_roots(@coefficients);

or

  use Math::Complex;  # The roots may be complex numbers.
  use Math::Polynomial::Solve
	qw(linear_roots quadratic_roots cubic_roots quartic_roots);

  # Find the roots of ax + b
  my @x1 = linear_roots($a, $b);

  # Find the roots of ax**2 + bx +c
  my @x2 = quadratic_roots($a, $b, $c);

  # Find the roots of ax**3 + bx**2 +cx + d
  my @x3 = cubic_roots($a, $b, $c, $d);

  # Find the roots of ax**4 + bx**3 +cx**2 + dx + e
  my @x4 = quartic_roots($a, $b, $c, $d, $e);

=head1 DESCRIPTION

This package supplies a set of functions that find the roots of
polynomials up to the quartic. There are no solutions for powers higher
than that at this time (partly because there are no general solutions
for fifth and higher powers).

The linear, quadratic, cubic, and quartic *_roots() functions all expect
to have a non-zero value for the $a term.

Passing a zero constant term means that the first value returned from
the function will always be zero, for all functions.

=head2 poly_roots()

A generic function that calls one of the other root-finding functions,
depending on the degree of the polynomial. Returns the solution for
polynomials of degree 1 to degree 4.

Unlike the other root-finding functions, it will check for coefficients
of zero for the highest power, and 'step down' the degree of the
polynomial to the appropriate case. Additionally, it will check for
coefficients of zero for the lowest power terms, and add zeros to its
root list before calling one of the root-finding functions. Therefore,
it is possible to solve a polynomial of degree higher than 4, as long as
it meets these rather specialized conditions.

=head2 linear_roots()

Here for completeness's sake more than anything else. Returns the
solution for

    ax + b = 0

by returning C<-b/a>. This may be in either a scalar or an array context.

=head2 quadratic_roots()

Gives the roots of the quadratic equation

    ax**2 + bx + c = 0

using the well-known quadratic formula. A two-element list is returned.

=head2 cubic_roots()

Gives the roots of the cubic equation

    ax**3 + bx**2 + cx + d = 0

by the method described by R. W. D. Nickalls (see the Acknowledgments
section below). A three-element list is returned. The first element will
always be real. The next two values will either be both real or both
complex numbers.

=head2 quartic_roots()

Gives the roots of the quartic equation

    ax**4 + bx**3 + cx**2 + dx + e = 0

using Ferrari's method (see the Acknowledgments section below). A
four-element list is returned. The first two elements will be either
both real or both complex. The next two elements will also be alike in
type.

=head2 EXPORT

There are no default exports. The functions may be named in an export list.

=head1 Acknowledgments

=head2 The cubic

The cubic is solved by the method described by R. W. D. Nickalls, "A New
Approach to solving the cubic: Cardan's solution revealed," The
Mathematical Gazette, 77, 354-359, 1993. This article is available on
the web at http://www.m-a.org.uk/eb/mg/mg077ch.pdf.

Dr. Nickalls was kind enough to send me his article, with notes and
revisions, and directed me to a Matlab script that was based on that
article, written by Herman Bruyninckx, of the Dept. Mechanical Eng.,
Div. PMA, Katholieke Universiteit Leuven, Belgium. This function is an
almost direct translation of that script, and I owe Herman Bruyninckx
for creating it in the first place. It may be found on the web at
http://www.mech.kuleuven.ac.be/~bruyninc/matlab/cubic.ml

Dick Nickalls, dicknickalls@compuserve.com

Herman Bruyninckx, Herman.Bruyninckx@mech.kuleuven.ac.be,
http://www.mech.kuleuven.ac.be/~bruyninc

=head2 The quartic

The method for quartic solution is Ferrari's, as described in the web
page Karl's Calculus Tutor, http://www.netsrq.com/~hahn/quartic.html.
I also made use of some short cuts mentioned in web page Ask Dr. Math FAQ,
http://forum.swarthmore.edu/dr.math/faq/faq.cubic.equations.html.

=head2 Other functionality

Matz Kindahl, the author of Math::Polynomial, suggested the poly_roots()
function.

=head1 SEE ALSO

Forsyth, George E., Michael A. Malcolm, and Cleve B. Moler (1977),
Computer Methods for Mathematical Computations, Prentice-Hall.

=head1 AUTHOR

John M. Gamble, jgamble@ripco.com

=cut

1;
__END__
