package Math::Polynomial::Solve;

require 5.006;

use Math::Complex;
use Carp;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use strict;
use warnings;
#use Smart::Comments;

@ISA = qw(Exporter);

#
# Export only on request.
#
%EXPORT_TAGS = (
	'classical' => [ qw(
		linear_roots
		quadratic_roots
		cubic_roots
		quartic_roots
	) ],
	'numeric' => [ qw(
		poly_roots
		get_hessenberg
		set_hessenberg
		get_substitution
		set_substitution
	) ],
	'sturm' => [ qw(
		poly_real_root_count
		poly_sturm_chain
		sturm_sign_chain
		sturm_sign_count
	) ],
	'utility' => [ qw(
		epsilon
		poly_antiderivative
		poly_derivative
		poly_constmult
		poly_divide
		poly_evaluate
		simplified_form
	) ],
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'classical'} }, @{ $EXPORT_TAGS{'numeric'} },
	@{ $EXPORT_TAGS{'sturm'} }, @{ $EXPORT_TAGS{'utility'} } );

our $VERSION = '2.54';

#
# Set to 1 to force poly_roots() to use the QR Hessenberg method
# regardless of the degree of the polynomial.  If set to zero,
# poly_roots() uses one of the specialized routines (linerar_roots(),
# quadratic_roots(), etc) if the degree of the polynomial is less than
# five.
#
my %option = (
	hessenberg => 1,
	varsubs => 0,
	roots => 0,
);

#
# Set up the epsilon variable, the value that is, in the floating-point
# math of the computer, the smallest value a variable can have before
# it is indistinguishable from zero when adding it to one.
#
my $epsilon;

BEGIN
{
	$epsilon = 0.25;
	my $epsilon2 = $epsilon/2.0;

	while (1.0 + $epsilon2 > 1.0)
	{
		$epsilon = $epsilon2;
		$epsilon2 /= 2.0;
	}
}

#
# sign($x);
#
#
sub sign($)
{
	my($x) = @_;
	return 1 if ($x > 0);
	return -1 if ($x < 0);
	return 0;
}

#
# $eps = epsilon();
# $oldeps = epsilon($neweps);
#
# Returns the machine epsilon value used internally by this module.
# If overriding the machine epsilon, returns the old value.
#
sub epsilon
{
	my $eps = $epsilon;
	$epsilon = $_[0] if (scalar @_ > 0);
	return $eps;
}

#
# Get/Set the flags that tells the module to use the QR Hessenberg
# method regardless of the degree of the polynomial; or to use
# substitution to reduce the apparent polynomial degree.
#
sub get_hessenberg
{
	return $option{hessenberg};
}

sub set_hessenberg
{
	$option{hessenberg} = ($_[0])? 1: 0;
}


#
# @x = linear_roots($a, $b)
#
#
sub linear_roots(@)
{
	my($a, $b) = @_;

	if (abs($a) < $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return ();
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

	if (abs($a) < $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return ();
	}

	return (0, -$b/$a) if (abs($c) < $epsilon);

	my $dis_sqrt = sqrt($b*$b - $a * 4 * $c);

	$dis_sqrt = -$dis_sqrt if ($b < $epsilon);	# Avoid catastrophic cancellation.

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

	if (abs($a) < $epsilon)
	{
		carp "The coefficient of the highest power must not be zero!\n";
		return @x;
	}

	return (0, quadratic_roots($a, $b, $c)) if (abs($d) < $epsilon);

	my $xN = -$b/3/$a;
	my $yN = $d + $xN * ($c + $xN * ($b + $a * $xN));

	my $two_a = 2 * $a;
	my $delta_sq = ($b * $b - 3 * $a * $c)/(9 * $a * $a);
	my $h_sq = 4/9 * ($b * $b - 3 * $a * $c) * $delta_sq**2;
	my $dis = $yN * $yN - $h_sq;
	my $twothirds_pi = (2 * pi)/3;

	#
	###            cubic_roots() calculations...
	#### $two_a
	#### $delta_sq
	#### $h_sq
	#### $dis
	#
	if ($dis > $epsilon)
	{
		#
		### Cubic branch 1, $dis is greater than  0...
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
		### Cubic branch 2, $dis is less than  0...
		#
		# Three distinct real roots.
		#
		my $theta = acos(-$yN/sqrt($h_sq))/3;
		my $delta = sqrt($b * $b - 3 * $a * $c)/(3 * $a);
		my $two_d = 2 * $delta;

		@x = ($xN + $two_d * cos($theta),
			$xN + $two_d * cos($twothirds_pi - $theta),
			$xN + $two_d * cos($twothirds_pi + $theta));
	}
	else
	{
		#
		### Cubic branch 3, $dis equals 0, within epsilon...
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
	# "resolvent cubic"  y**4 + fy**2 + gy + h.
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

	#
	###            quartic_roots calculations
	#### $b4
	#### $f
	#### $g
	#### $h
	#
	if (abs($h) < $epsilon)
	{
		#
		### Quartic branch 1, $h equals 0, within epsilon...
		#
		# Special case: h == 0.  We have a cubic times y.
		#
		@x = (0, cubic_roots(1, 0, $f, $g));
	}
	elsif (abs($g * $g) < $epsilon)
	{
		#
		### "Quartic branch 2, $g equals 0, within epsilon...
		#
		# Another special case: g == 0.  We have a quadratic
		# with y-squared.
		#
		# (We check $g**2 because that's what the constant
		# value actually is in Ferrari's method, and it is
		# possible for $g to be outside of epsilon while
		# $g**2 is inside, i.e., "zero").
		#
		my($p, $q) = quadratic_roots(1, $f, $h);
		$p = sqrt($p);
		$q = sqrt($q);
		@x = ($p, -$p, $q, -$q);
	}
	else
	{
		#
		### Quartic branch 3, Ferrari's method...
		#
		# Special cases don't apply, so continue on with Ferrari's
		# method.  This involves setting up the resolvent cubic
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
		my $z;
		($z, undef, undef) = cubic_roots(1, 2*$f, $f*$f - 4*$h, -$g*$g);

		### $z

		my $alpha = sqrt($z);
		my $rho = $g/$alpha;
		my $beta = ($f + $z - $rho)/2;
		my $gamma = ($f + $z + $rho)/2;

		@x = quadratic_roots(1, $alpha, $beta);
		push @x, quadratic_roots(1, -$alpha, $gamma);
	}

	return ($x[0] - $b4, $x[1] - $b4, $x[2] - $b4, $x[3] - $b4);
}


# Perl code to find roots of a polynomial translated by Nick Ing-Simmons
# <Nick@Ing-Simmons.net> from FORTRAN code by Hiroshi Murakami.
# From the netlib archive: http://netlib.bell-labs.com/netlib/search.html
# In particular http://netlib.bell-labs.com/netlib/opt/companion.tgz

#       BASE is the base of the floating point representation on the machine.
#       It is 16 for base 16 float : for example, IBM system 360/370.
#       It is 2  for base  2 float : for example, IEEE float.

my $MAX_ITERATIONS = 60;
sub BASE ()    { 2 }
sub BASESQR () { BASE * BASE }

#
# $matrix_ref = build_companion(@coefficients);
#
# Build the Companion Matrix of the N degree polynomial.  Return a
# reference to the N by N matrix.
#
sub build_companion(@)
{
	my @coefficients = @_;
	my $n = $#coefficients;
	my @h;			# The matrix.

	#
	#### build_companion called with: @coefficients
	#
	# First step:  Divide by the leading coefficient.
	#
	my $cn = shift @coefficients;

	foreach my $c (@coefficients)
	{
		$c /= $cn;
	}

	#
	# Why would we be calling this for a linear equation?
	# Who knows, but if we are, then we can skip all the
	# complicated looping.
	#
	if ($n == 1)
	{
		$h[1][1] = -$coefficients[0];
		return \@h;
	}

	#
	# Next: set up the diagonal matrix.
	#
	for my $i (1 .. $n)
	{
		for my $j (1 .. $n)
		{
			$h[$i][$j] = 0.0;
		}
	}

	for my $i (2 .. $n)
	{
		$h[$i][$i - 1] = 1.0;
	}

	#
	# And put in the coefficients.
	#
	for my $i (1 .. $n)
	{
		$h[$i][$n] = - (pop @coefficients);
	}

	#
	# Now we balance the matrix.
	#
	# Balancing the unsymmetric matrix A.
	# Perl code translated by Nick Ing-Simmons <Nick@Ing-Simmons.net>
	# from FORTRAN code by Hiroshi Murakami.
	#
	#  The Fortran code is based on the Algol code "balance" from paper:
	#  "Balancing a Matrix for Calculation of Eigenvalues and Eigenvectors"
	#  by B. N. Parlett and C. Reinsch, Numer. Math. 13, 293-304(1969).
	#
	#  Note: The only non-zero elements of the companion matrix are touched.
	#
	my $noconv = 1;
	while ($noconv)
	{
		$noconv = 0;
		for my $i (1 .. $n)
		{
			#
			# Touch only non-zero elements of companion.
			#
			my $c;
			if ($i != $n)
			{
				$c = abs($h[$i + 1][$i]);
			}
			else
			{
				$c = 0.0;
				for my $j (1 .. $n - 1)
				{
					$c += abs($h[$j][$n]);
				}
			}

			my $r;
			if ($i == 1)
			{
				$r = abs($h[1][$n]);
			}
			elsif ($i != $n)
			{
				$r = abs($h[$i][$i - 1]) + abs($h[$i][$n]);
			}
			else
			{
				$r = abs($h[$i][$i - 1]);
			}

			next if ($c == 0.0 || $r == 0.0);

			my $g = $r / BASE;
			my $f = 1.0;
			my $s = $c + $r;
			while ( $c < $g )
			{
				$f = $f * BASE;
				$c = $c * BASESQR;
			}

			$g = $r * BASE;
			while ($c >= $g)
			{
				$f = $f / BASE;
				$c = $c / BASESQR;
			}

			if (($c + $r) < 0.95 * $s * $f)
			{
				$g = 1.0 / $f;
				$noconv = 1;

				#C Generic code.
				#C   do $j=1,$n
				#C	 $h($i,$j)=$h($i,$j)*$g
				#C   enddo
				#C   do $j=1,$n
				#C	 $h($j,$i)=$h($j,$i)*$f
				#C   enddo
				#C begin specific code. Touch only non-zero elements of companion.
				if ($i == 1)
				{
					$h[1][$n] *= $g;
				}
				else
				{
					$h[$i][$i - 1] *= $g;
					$h[$i][$n] *= $g;
				}
				if ($i != $n)
				{
					$h[$i + 1][$i] *= $f;
				}
				else
				{
					for my $j (1 .. $n)
					{
						$h[$j][$i] *= $f;
					}
				}
			}
		}	# for $i
	}	# while $noconv

	return \@h;
}

#
# @roots = hqr_eigen_hessenberg($matrix_ref)
#
# Finds the eigenvalues of a real upper Hessenberg matrix,
# H, stored in the array $h(1:n,1:n).  Returns a list
# of real and/or complex numbers.
#
sub hqr_eigen_hessenberg($)
{
	my $ref = shift;
	my @h   = @$ref;
	my $n   = $#h;

	#
	#
	# Eigenvalue Computation by the Householder QR method for the Real Hessenberg matrix.
	# Perl code translated by Nick Ing-Simmons <Nick@Ing-Simmons.net>
	# from FORTRAN code by Hiroshi Murakami.
	# The Fortran code is based on the Algol code "hqr" from the paper:
	#   "The QR Algorithm for Real Hessenberg Matrices"
	#   by R. S. Martin, G. Peters and J. H. Wilkinson,
	#   Numer. Math. 14, 219-231(1970).
	#
	#
	my($p, $q, $r);
	my($w, $x, $y);
	my($s, $z );
	my $t = 0.0;

	my @w;

	ROOT:
	while ($n > 0)
	{
		my $its = 0;
		my $na  = $n - 1;

		while ($its < $MAX_ITERATIONS)
		{
			#
			# Look for single small sub-diagonal element;
			#
			my $l;
			for ($l = $n; $l >= 2; $l--)
			{
				last if ( abs( $h[$l][ $l - 1 ] ) <= $epsilon *
					( abs( $h[ $l - 1 ][ $l - 1 ] ) + abs( $h[$l][$l] ) ) );
			}

			$x = $h[$n][$n];

			if ($l == $n)
			{
				#
				# One (real) root found.
				#
				push @w, $x + $t;
				$n--;
				next ROOT;
			}

			$y = $h[$na][$na];
			$w = $h[$n][$na] * $h[$na][$n];

			if ($l == $na)
			{
				$p = ( $y - $x ) / 2;
				$q = $p * $p + $w;
				$y = sqrt( abs($q) );
				$x += $t;

				if ($q > 0.0)
				{
					#
					# Real pair.
					#
					$y = -$y if ( $p < 0.0 );
					$y += $p;
					push @w, $x - $w / $y;
					push @w, $x + $y;
				}
				else
				{
					#
					# Complex or twin pair.
					#
					push @w, $x + $p - $y * i;
					push @w, $x + $p + $y * i;
				}

				$n -= 2;
				next ROOT;
			}

			croak "Too many iterations ($its) at n=$n\n" if ($its == $MAX_ITERATIONS);

			if ($its && $its % 10 == 0)
			{
				#
				# Form exceptional shift.
				#
				#### Exceptional shift at: $its
				#

				$t += $x;
				for (my $i = 1; $i <= $n; $i++)
				{
					$h[$i][$i] -= $x;
				}

				$s = abs($h[$n][$na]) + abs($h[$na][$n - 2]);
				$y = 0.75 * $s;
				$x = $y;
				$w = -0.4375 * $s * $s;
			}

			$its++;

			#
			# Look for two consecutive small sub-diagonal elements.
			#
			my $m;
			for ($m = $n - 2 ; $m >= $l ; $m--)
			{
				$z = $h[$m][$m];
				$r = $x - $z;
				$s = $y - $z;
				$p = ($r * $s - $w) / $h[$m + 1][$m] + $h[$m][$m + 1];
				$q = $h[$m + 1][$m + 1] - $z - $r - $s;
				$r = $h[$m + 2][$m + 1];

				$s = abs($p) + abs($q) + abs($r);
				$p /= $s;
				$q /= $s;
				$r /= $s;

				last if ($m == $l);
				last if (
					abs($h[$m][$m - 1]) * (abs($q) + abs($r)) <=
					$epsilon * abs($p) * (
						  abs($h[$m - 1][$m - 1]) +
						  abs($z) +
						  abs($h[$m + 1][$m + 1])
					)
				  );
			}

			for (my $i = $m + 2; $i <= $n; $i++)
			{
				$h[$i][$i - 2] = 0.0;
			}
			for (my $i = $m + 3; $i <= $n; $i++)
			{
				$h[$i][$i - 3] = 0.0;
			}

			#
			# Double QR step involving rows $l to $n and
			# columns $m to $n.
			#
			for (my $k = $m; $k <= $na; $k++)
			{
				my $notlast = ($k != $na);
				if ($k != $m)
				{
					$p = $h[$k][$k - 1];
					$q = $h[$k + 1][$k - 1];
					$r = ($notlast)? $h[$k + 2][$k - 1]: 0.0;

					$x = abs($p) + abs($q) + abs($r);
					next if ( $x == 0.0 );

					$p /= $x;
					$q /= $x;
					$r /= $x;
				}

				$s = sqrt($p * $p + $q * $q + $r * $r);
				$s = -$s if ($p < 0.0);

				if ($k != $m)
				{
					$h[$k][$k - 1] = -$s * $x;
				}
				elsif ($l != $m)
				{
					$h[$k][$k - 1] *= -1;
				}

				$p += $s;
				$x = $p / $s;
				$y = $q / $s;
				$z = $r / $s;
				$q /= $p;
				$r /= $p;

				#
				# Row modification.
				#
				for (my $j = $k; $j <= $n; $j++)
				{
					$p = $h[$k][$j] + $q * $h[$k + 1][$j];

					if ($notlast)
					{
						$p += $r * $h[ $k + 2 ][$j];
						$h[ $k + 2 ][$j] -= $p * $z;
					}

					$h[ $k + 1 ][$j] -= $p * $y;
					$h[$k][$j] -= $p * $x;
				}

				my $j = $k + 3;
				$j = $n if $j > $n;

				#
				# Column modification.
				#
				for (my $i = $l; $i <= $j; $i++)
				{
					$p = $x * $h[$i][$k] + $y * $h[$i][$k + 1];

					if ($notlast)
					{
						$p += $z * $h[$i][$k + 2];
						$h[$i][$k + 2] -= $p * $r;
					}

					$h[$i][$k + 1] -= $p * $q;
					$h[$i][$k] -= $p;
				}
			}	# for $k
		}	# while $its
	}	# while $n
	return @w;
}

#
# @x = poly_roots(@coefficients)
#
# Coefficients are fed in highest degree first.  Equation 5x**5 + 4x**4 + 2x + 8
# would be fed in with @x = poly_roots(5, 4, 0, 0, 2, 8);
#
sub poly_roots(@)
{
	my(@coefficients) = @_;
	my(@x, @zero_x);

	#
	#### @coefficients
	#
	# Check for zero coefficients in the higher-powered terms.
	#
	shift @coefficients while (@coefficients and abs($coefficients[0]) < $epsilon);

	if (@coefficients == 0)
	{
		carp "All coefficients are zero\n";
		return (0);
	}

	#
	# How about zero coefficients in the low terms?
	#
	while (@coefficients and abs($coefficients[$#coefficients]) < $epsilon)
	{
		push @zero_x, 0;
		pop @coefficients;
	}

	#
	# Next do some minor analysis of the remaining coefficients.
	# Whether we use this or not depends upon some internal flags.
	#
	# my %coef_reduc = poly_analysis(@coefficients);

	#
	# If the remaining polynomial is a quintic or higher, or
	# if $option{hessenberg} is set, continue with the matrix
	# calculation.
	#
	### %option
	#
	if ($option{hessenberg} or $#coefficients > 4)
	{
		my $matrix_ref = build_companion(@coefficients);

		#### Balanced Companion Matrix (row and column 0 will be undefs)...
		#### $matrix_ref

		#
		# QR iterations from the matrix.
		#
		push @x, hqr_eigen_hessenberg($matrix_ref);
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

	unshift @x, @zero_x;
	return @x;
}

#
# Nothing to see here, move along.
#
# STILL EXPERIMENTAL.
#
#
# @x = map(root($_, 2), @x) if ($czop);
#
sub poly_analysis(@)
{
	my(@coefficients) = @_;
	my $nzc = 0;		# Number of zero coefficients.
	my $czop = 1;		# Coefficients zero at odd powers? (1==T,0==F).
	for my $j (0..$#coefficients)
	{
		if (abs($coefficients[$j]) < $epsilon)
		{
			$nzc++;
		}
		else
		{
			$czop = 0 if ($j & 1);
		}
	}

	#
	# Don't bother substituting if we can use the roots() function.
	#
	$czop = 0 if ($nzc == 2);

	if ($czop == 1)
	{
		my @even_coefs;
		push @even_coefs, $coefficients[$_*2] for (0..$#coefficients/2);
		@coefficients = @even_coefs;
	}
}

#
# @monic_polynomial = simplified_form(@coefficients);
#
# Return polynomial without any leading zero coefficients and in
# a monic polynomial form (all coefficients divided by the coefficient
# of the highest power).
#
sub simplified_form(@)
{
	my @coefficients = @_;

	shift @coefficients while (scalar @coefficients and abs($coefficients[0]) < $epsilon);

	if (scalar @coefficients == 0)
	{
		carp "All coefficients are zero\n";
		return (0);
	}

	my $a = $coefficients[0];
	$coefficients[$_] /= $a for (0..$#coefficients);

	return @coefficients;
}

#
# @derived = poly_derivative(@coefficients)
#
# Returns the derivative of a polynomial. The constant value is
# lost of course.
#
sub poly_derivative(@)
{
	my @coefficients = @_;
	my $degree = $#coefficients;

	return () if ($degree < 1);

	$coefficients[$_] *= $degree-- for (0..$degree - 2);

	pop @coefficients;
	return @coefficients;
}

#
# @integral = poly_antiderivative(@coefficients)
#
# Returns the antiderivative of a polynomial. The constant value is
# always set to zero; to override this $integral[$#integral] = $const;
#
sub poly_antiderivative(@)
{
	my @coefficients = @_;
	my $degree = scalar @coefficients;

	return (0) if ($degree < 1);

	$coefficients[$_] /= $degree-- for (0..$degree - 2);

	push @coefficients, 0;
	return @coefficients;
}

#
# @results = poly_evaluate(\@coefficients, \@values);
#
# Returns a list of y-points on the polynomial for a corresponding
# list of x-points, using Horner's method.
#
sub poly_evaluate($$)
{
	my $coef_ref = shift;
	my $value_ref = shift;

	my @coefficients = @$coef_ref;
	my @values = @$value_ref;

	my @results = (shift @coefficients) x scalar @values;

	foreach my $c (@coefficients)
	{
		foreach my $j (0..$#values)
		{
			$results[$j] = $results[$j] * $values[$j] + $c;
		}
	}
	return @results;
}

#
# ($q_ref, $r_ref) = poly_divide(\@coefficients1, \@coefficients2);
#
# Synthetic division for polynomials. Returns references to the quotient
# and the remainder.
#
sub poly_divide($$)
{
	my $n_ref = shift;
	my $d_ref = shift;

	my @numerator = @$n_ref;
	my @divisor = @$d_ref;
	my @quotient;

	#
	# Just checking... removing any leading zeros.
	#
	shift @numerator while (@numerator and abs($numerator[0]) < $epsilon);
	shift @divisor while (@divisor and abs($divisor[0]) < $epsilon);

	my $n_degree = $#numerator;
	my $d_degree = $#divisor;
	my $q_degree = $n_degree - $d_degree;

	return ([0], \@numerator) if ($q_degree < 0);
	return (undef, undef) if ($d_degree < 0);

	#
	###Dividing:
	### @numerator
	### by
	### @divisor
	#
	my $lead_coefficient = $divisor[0];

	#
	# Perform the synthetic division. The remainder will
	# be what's left in the numerator.
	#
	for my $j (0..$q_degree)
	{
		#
		# Get the next term for the quotient. We shift
		# off the lead numerator term, which would become
		# zero due to subtraction anyway.
		#
		my $q = (shift @numerator)/$lead_coefficient;

		push @quotient, $q;

		for my $k (1..$d_degree)
		{
			$numerator[$k - 1] -= $q * $divisor[$k];
		}
	}

	#
	# And once again, check for leading zeros in the remainder.
	#
	shift @numerator while (@numerator and abs($numerator[0]) < $epsilon);
	push @numerator, 0 unless (@numerator);
	return (\@quotient, \@numerator);
}

#
# @new_coeffients = poly_constmult(\@coefficients, $multiplier);
#
sub poly_constmult($$)
{
	my($c_ref, $multiplier) = @_;
	my @coefficients = @$c_ref;

	return map($_ *= $multiplier, @coefficients);
}

#
# @sturm_seq = poly_sturm_chain(@coefficients)
#
#
sub poly_sturm_chain(@)
{
	my @coefficients = @_;
	my $degree = $#coefficients;
	my @chain;
	my($q, $r);

	my $f1 = [@coefficients];
	my $f2 = [poly_derivative(@coefficients)];

	push @chain, $f1;

	return @chain if ($degree < 1);

	push @chain, $f2;

	return @chain if ($degree < 2);

	do
	{
		($q, $r) = poly_divide($f1, $f2);
		$f1 = $f2;
		$f2 = [poly_constmult($r, -1)];
		push @chain, $f2;
	}
	while ($#$r > 0);

	#
	## poly_sturm_chain:
	### @chain
	#
	return @chain;
}

#
# $root_count = poly_real_root_count(@coefficients);
#
# An all-in-one function for finding the number of real roots in
# a polynomial. Use this if you don't intend to do anything else
# requiring the Sturm chain.
#
sub poly_real_root_count(@)
{
	my(@coefficients) = @_;

	my @chain = poly_sturm_chain(@coefficients);

	return sturm_sign_count(sturm_sign_minus_inf(\@chain)) -
		sturm_sign_count(sturm_sign_plus_inf(\@chain));
}

#
# @signs = sturm_minus_inf(\@chain);
#
# Return an array of signs from the chain at minus infinity.
#
sub sturm_sign_minus_inf($)
{
	my($chain_ref) = @_;
	my @signs;

	foreach my $c (@$chain_ref)
	{
		my @coefficients = @$c;
		push @signs, ((($#coefficients & 1) == 1)? -1: 1) * sign($coefficients[0]);
	}

	return @signs
}

#
# @signs = sturm_plus_inf(\@chain);
#
# Return an array of signs from the chain at infinity.
#
sub sturm_sign_plus_inf($)
{
	my($chain_ref) = @_;
	my @signs;

	foreach my $c (@$chain_ref)
	{
		my @coefficients = @$c;
		push @signs, sign($coefficients[0]);
	}

	return @signs
}

#
# @sign_chains = sturm_sign_chain(\@chain, \@xvals);
#
# Return an array of signs for each x-value passed in each function in
# the Sturm chain.
#
sub sturm_sign_chain($$)
{
	my($chain_ref, $xvals_ref) = @_;
	my $fn_count = $#$chain_ref;
	my $x_count = $#$xvals_ref;
	my @sign_chain;
	my $col = 0;

	push @sign_chain, [] for (0..$x_count);

	foreach my $p_ref (@$chain_ref)
	{
		my @ysigns = map($_ = sign($_), poly_evaluate($p_ref, $xvals_ref));

		#
		# We just retrieved the signs of a single function across
		# our x-vals. We want it the other way around; signs listed
		# by x-val across functions.
		#
		# (list of lists)
		# |
		# v
		#      f0   f1   f2   f3   f4   ...
		# x0    -    -    +    -    +    (list 0)
		#
		# x1    +    -    -    +    +    (list 1)
		#
		# x2    +    -    +    +    +    (list 2)
		#
		# ...
		#
		for my $j (0..$x_count)
		{
			push @{$sign_chain[$j]}, shift @ysigns;
		}

		$col++;
	}

	return @sign_chain;
}

#
# $sign_changes = sturm_sign_count(@signs);
#
# Count the number of changes from sign to sign in the array.
#
sub sturm_sign_count(@)
{
	my @sign_seq = @_;
	my $scnt = 0;

	my $s1 = shift @sign_seq;
	for my $s2 (@sign_seq)
	{
		$scnt++ if ($s1 != $s2);
		$s1 = $s2;
	}

	return $scnt;
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
  use Math::Polynomial::Solve qw(:numeric);  # See the EXPORT section

  #
  # Find roots using the matrix method.
  #
  my @x = poly_roots(@coefficients);

  #
  # Alternatively, use the classical methods instead of the matrix
  # method if the polynomial degree is less than five.
  #
  set_hessenberg(0);
  my @x = poly_roots(@coefficients);

or

  use Math::Complex;  # The roots may be complex numbers.
  use Math::Polynomial::Solve qw(:classical);  # See the EXPORT section

  #
  # Find the polynomial roots using the classical methods.
  #

  # Find the roots of ax + b
  my @x1 = linear_roots($a, $b);

  # Find the roots of ax**2 + bx +c
  my @x2 = quadratic_roots($a, $b, $c);

  # Find the roots of ax**3 + bx**2 +cx + d
  my @x3 = cubic_roots($a, $b, $c, $d);

  # Find the roots of ax**4 + bx**3 +cx**2 + dx + e
  my @x4 = quartic_roots($a, $b, $c, $d, $e);

or

  use Math::Polynomial::Solve qw(:utility);

  my @coefficients = (89, 23, 23, 432, 27);

  # Return a version of the polynomial with no leading zeroes
  # and the leading coefficient equal to 1.
  my @monic_form = simplified_form(@coefficients);

  # Find the y-values of the polynomial at selected x-values.
  my @xvals = (0, 1, 2, 3, 5, 7);
  my @yvals = poly_evaluate(\@coefficients, \@xvals);

or

  use Math::Polynomial::Solve qw(:sturm);

  # Find the number of unique real roots of the polynomial.
  my $no_of_unique_roots = poly_real_root_count(@coefficients);

=head1 DESCRIPTION

This package supplies a set of functions that find the roots of
polynomials, along with some utility functions. Polynomials up to the quartic
may be solved directly by numerical formulae. Polynomials of fifth and higher
powers will be solved by an iterative method, as there are no general solutions
for fifth and higher powers.

If the constant term is zero then the first value returned in the list
of answers will always be zero, for all functions.

The leading coefficient C<$a> must always be non-zero for the classical
functions C<linear_roots()>, C<quadratic_roots()>, C<cubic_roots()>, and
C<quartic_roots()>.

Functions making use of the Sturm sequence are also available, letting you
find the number of real roots present in a range of X values.

In addition to the root-finding functions, the internal functions have
also been exported for your use. See the L</"EXPORT"> section for a list of
functions exported via the :utiltiy tag.

=head2 Functions

=head3 get_hessenberg()

Returns 1 or 0 depending upon whether C<poly_roots()> always makes use of
the Hessenberg matrix method or not.

B<NOTE>: this function will be deprecated in future releases in
favor of a hash-like option function.

=head3 set_hessenberg()

Sets or removes the condition that forces the use of the Hessenberg matrix
regardless of the polynomial's degree.  A zero argument forces the
use of classical methods for polynomials of degree less than five, a
non-zero argument forces C<poly_roots()> to always use the matrix method.
The default state of the module is to always use the matrix method.
This is a complete change from the default behavior in versions less than v2.50.

B<NOTE>: this function will be deprecated in future releases in
favor of a hash-like option function.

=head3 poly_roots()

Returns the roots of a polynomial equation, regardless of degree.
Unlike the other root-finding functions, it will check for coefficients
of zero for the highest power, and 'step down' the degree of the
polynomial to the appropriate case. Additionally, it will check for
coefficients of zero for the lowest power terms, and add zeros to its
root list before calling one of the root-finding functions.

By default, C<poly_roots()> will use the Hessenberg matrix method for solving
polynomials.

If the function C<set_hessenberg()> is called with an argument of 0,
C<poly_roots()> attempts to use one of the classical root-finding functions
listed below, if the degree of the polynomial is four or less.

=head3 linear_roots()

Here for completeness's sake more than anything else. Returns the
solution for

    ax + b = 0

by returning C<-b/a>. This may be in either a scalar or an array context.

=head3 quadratic_roots()

Gives the roots of the quadratic equation

    ax**2 + bx + c = 0

using the well-known quadratic formula. Returns a two-element list.

=head3 cubic_roots()

Gives the roots of the cubic equation

    ax**3 + bx**2 + cx + d = 0

by the method described by R. W. D. Nickalls (see the L</"Acknowledgments">
section below). Returns a three-element list. The first element will
always be real. The next two values will either be both real or both
complex numbers.

=head3 quartic_roots()

Gives the roots of the quartic equation

    ax**4 + bx**3 + cx**2 + dx + e = 0

using Ferrari's method (see the L</"Acknowledgments"> section below). Returns
a four-element list. The first two elements will be either
both real or both complex. The next two elements will also be alike in
type.

=head3 poly_real_root_count()

Return the number of I<unique>, I<real> roots of the polynomial.

    $unique_roots = poly_real_root_count(@coefficients);

For example, the equation C<(x + 3)**3> forms the polynomial C<x**3 + 9x**2 + 27x + 27>,
but C<poly_real_root_count(1, 9, 27, 27)> will return 1 for that polynomial since all
three roots are identical.

This function is the all-in-one function to use instead of

    my @chain = poly_sturm_chain(@coefficients);

    return sturm_sign_count(sturm_sign_minus_inf(\@chain)) -
            sturm_sign_count(sturm_sign_plus_inf(\@chain));

if you don't intend to use the Sturm chain for anything else.

=head3 poly_sturm_chain()

Returns the chain of Sturm functions used to evaluate the number of roots of a
polynomial in a range of X values. See C<poly_real_root_count()> for an example.

=head3 sturm_sign_minus_inf()

=head3 sturm_sign_plus_inf()

=head3 sturm_sign_chain()

=head3 sturm_sign_count()

Return an array of signs (or, an array of array of signs in the case of
C<sturm_sign_chain()>) for use by C<sturm_sign_count()>.

See C<poly_real_root_count()> for an example of the use of
C<sturm_sign_minus_inf()> and C<sturm_sign_plus_inf()>.

C<sturm_sign_chain()> may be used to determine the number of roots between a
pair or more of X values.

For example:

    my @chain = poly_sturm_chain( @coef );
    my @signs = sturm_sign_chain(\@chain, \@xvals);

    print "Number of unique, real, roots between ", $xval[0], " and ", $xval[1],
          " is ", sturm_sign_count(@{$signs[0]}) - sturm_sign_count(@{$signs[1]});

Or, to find the number of positive, unique, real, roots:

    my @xvals = (0);
    my @signs = sturm_sign_chain(\@chain, \@xvals);

    print "Number of positve, unique, real, roots is ",
          sturm_sign_count(@{$signs[0]}) - sturm_sign_count(sturm_sign_plus_inf(\@chain));

=head3 poly_derivative()

    @derivative = poly_derivative(@coefficients);

Returns the coefficients of the first derivative of the polynomial. Because
leading zeros are removed before returning the derivative, the resulting
polynomial may be reduced by more than just one than the length of the original
polynomial. Returns an empty list if the polynomial is a simple constant.

=head3 poly_antiderivative()

Returns the coefficients of the antiderivative of the polynomial. The
constant term is set to zero; to override this use

    @integral = poly_antiderivative(@coefficients);
    $integral[$#integral] = $const_term;

=head3 epsilon()

Returns the machine epsilon value that was calculated when this module was loaded.

The value may be changed, although this in general is not recommended.

    my $old_epsilon = epsilon($new_epsilon);

The previous value of epsilon may be saved to be restored later.

The Wikipedia article at L<http://en.wikipedia.org/wiki/Machine_epsilon/> has
more information on the subject.

=head3 simplified_form()

Return the polynomial adjusted by removing any leading zero coefficients
and placing it in a monic polynomial form (all coefficients divided by the
coefficient of the highest power).

=head3 poly_evaluate()

Returns the values of the polynomial given a list of arguments. Unlike
the above functions, this takes the reference of the coefficient list, in
order to feed the multiple x-values (that are also passed in as a reference).

    my @polynomial = (1, -12, 0, 8, 13);
    my @xvals = (0, 1, 2, 3, 5, 7);
    my @yvals = poly_evaluate(\@polynomial, \@xvals);

    print "Polynomial: [", join(", ", @polynomial), "]\n";

    for my $j (0..$#yvals) {
        print "Evaluates at ", $xvals[$j], " to ", $yvals[$j], "\n";
    }

=head3 poly_constmult()

Simple function to multiply all of the coefficients by a constant. Like
C<poly_evaluate()>, uses the reference of the coefficient list.

    my @polynomial = (1, 7, 0, 12, 19);
    my @polynomial3 = poly_constmult(\@polynomial, 3);

=head3 poly_divide()

Divide one polynomial by another. Like C<poly_evaluate()>, the function takes
a reference to the coefficient list. It returns a reference to both a quotient
and a remainder.

    my @polynomial = (1, -13, 59, -87);
    my @polydiv = (3, -26, 59);
    my($q, $r) = poly_divide(\@polynomial, \@polydiv);
    my @quotient = @$q;
    my @remainder = @$r;

=head1 EXPORT

There are no default exports. The functions may be named in an export list.

There are also four export tags.

=over 3

=item classical

Exports the four root-finding functions for polynomials of degree less than
five: C<linear_roots()>, C<quadratic_roots()>, C<cubic_roots()>, C<quartic_roots()>.

=item numeric

Exports the root-finding function and the functions that affect its behavior:
C<poly_roots()>, C<get_hessenberg()> and C<set_hessenberg()>. Note that
C<get_hessenberg()> and C<set_hessenberg()> will be deprecated in the next release.

=item sturm

Exports the functions that provide the Sturm functions: C<poly_sturm_chain()>,
C<poly_real_root_count()>, C<sturm_sign_count()>, C<sturm_sign_minus_inf()>,
C<sturm_sign_plus_inf()>, and C<sturm_sign_chain()>. 

=item utility

Exports the functions that are used internally by other functions, and which
might be useful to you as well: C<epsilon()>, C<poly_evaluate()>,
C<poly_derivative()>, C<poly_antiderivatve()>, C<poly_constmult()>,
C<poly_divide()>, and C<simplified_form()>.

=back

=head1 Acknowledgments

=head2 The cubic

The cubic is solved by the method described by R. W. D. Nickalls, "A New
Approach to solving the cubic: Cardan's solution revealed," The
Mathematical Gazette, 77, 354-359, 1993.

Dr. Nickalls was kind enough to send me his article, with notes and
revisions, and directed me to a Matlab script that was based on that
article, written by Herman Bruyninckx, of the Dept. Mechanical Eng.,
Div. PMA, Katholieke Universiteit Leuven, Belgium. This function is an
almost direct translation of that script, and I owe Herman Bruyninckx
for creating it in the first place. 

Beginning with version 2.51, Dr. Nikalls's paper is included in the references
directory of this package. Dr. Nickalls has also made his paper available at
L<http://www.nickalls.org/dick/papers/maths/cubic1993.pdf>.

This article is also available on L<http://www.2dcurves.com/cubic/cubic.html>,
and there is a nice discussion of his method at
L<http://www.sosmath.com/algebra/factor/fac111/fac111.html>.

Dick Nickalls, dick@nickalls.org

Herman Bruyninckx, Herman.Bruyninckx@mech.kuleuven.ac.be,
has web page at L<http://www.mech.kuleuven.ac.be/~bruyninc>.
His matlab cubic solver is at
L<http://people.mech.kuleuven.ac.be/~bruyninc/matlab/cubic.m>.

Andy Stein has written a version of cubic.m that will work with
vectors.  It is included with this package in the eg directory.

=head2 The quartic

The method for quartic solution is Ferrari's, as described in the web
page Karl's Calculus Tutor at L<http://www.karlscalculus.org/quartic.html>.
I also made use of some short cuts mentioned in web page Ask Dr. Math FAQ,
at L<http://forum.swarthmore.edu/dr.math/faq/faq.cubic.equations.html>.

=head2 Quintic and higher.

Back when this module could only solve polynomials of degrees 1 through 4,
Matz Kindahl, the author of Math::Polynomial, suggested the C<poly_roots()>
function. Later on, Nick Ing-Simmons, who was working on a perl binding
to the GNU Scientific Library, sent a perl translation of Hiroshi
Murakami's Fortran implementation of the QR Hessenberg algorithm, and it
fit very well into the C<poly_roots()> function. Quintics and higher degree
polynomials can now be solved, albeit through numeric analysis methods.

Hiroshi Murakami's Fortran routines were at
L<http://netlib.bell-labs.com/netlib/>, but do not seem to be available
from that source anymore.

He referenced the following articles:

R. S. Martin, G. Peters and J. H. Wilkinson, "The QR Algorithm for Real Hessenberg
Matrices", Numer. Math. 14, 219-231(1970).

B. N. Parlett and C. Reinsch, "Balancing a Matrix for Calculation of Eigenvalues
and Eigenvectors", Numer. Math. 13, 293-304(1969).

Alan Edelman and H. Murakami, "Polynomial Roots from Companion Matrix
Eigenvalues", Math. Comp., v64,#210, pp.763-776(1995).

For starting out, you may want to read

William Press, Brian P. Flannery, Saul A. Teukolsky, and William T. Vetterling I<Numerical Recipes in C>.
Cambridge University Press, 1988.
They have a web site for their book, L<http://www.nr.com/>.

=head2 Sturm's Sequence

Dörrie, Heinrich. I<100 Great Problems of Elementary Mathematics; Their History and Solution>.
New York: Dover Publications, 1965. Translated by David Antin.

Discusses Charles Sturm's 1829 paper with an eye towards mathematical proof
rather than an algorithm, but is still very useful.

Glassner, Andrew S. I<Graphics Gems>. Boston: Academic Press, 1990. 

The chapter "Using Sturm Sequences to Bracket Real Roots
of Polynomial Equations" (by D. G. Hook and P. R. McAree) has a clearer
description of the actual steps needed to implement Sturm's method.

=head1 SEE ALSO

Forsythe, George E., Michael A. Malcolm, and Cleve B. Moler
I<Computer Methods for Mathematical Computations>. Prentice-Hall, 1977.

=head1 AUTHOR

John M. Gamble may be found at B<jgamble@cpan.org>

=cut
