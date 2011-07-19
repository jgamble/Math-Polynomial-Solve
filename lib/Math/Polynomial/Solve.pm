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
		poly_option
		get_hessenberg
		set_hessenberg
	) ],
	'sturm' => [ qw(
		poly_real_root_count
		poly_sturm_chain
		sturm_real_root_range_count
		sturm_bisection_roots
		sturm_sign_count
		sturm_sign_chain
		sturm_sign_minus_inf
		sturm_sign_plus_inf
	) ],
	'utility' => [ qw(
		epsilon
		fltcmp
		poly_iteration
		laguerre
		poly_antiderivative
		poly_derivative
		poly_constmult
		poly_divide
		poly_evaluate
		poly_nonzero_term_count
		simplified_form
	) ],
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'classical'} }, @{ $EXPORT_TAGS{'numeric'} },
	@{ $EXPORT_TAGS{'sturm'} }, @{ $EXPORT_TAGS{'utility'} } );

our $VERSION = '2.61';

#
# Options to set or unset to force poly_roots() to use different
# methods of solving.
#
# hessenberg (default 1): set to 1 to force poly_roots() to use the QR
# Hessenberg method # regardless of the degree of the polynomial.  Set to zero
# to force poly_roots() uses one of the specialized routines (linerar_roots(),
# quadratic_roots(), etc) if the degree of the polynomial is less than five.
#
# root_function (default 0): set to 1 to force poly_roots() to use
# Math::Complex's root(-c/a, n) function if the polynomial is of the form
# ax**n + c.
#
# varsubst (default 0): try to reduce the degree of the polynomial through
# variable substitution before solving.
#
my %option = (
	hessenberg => 1,
	root_function => 0,
	varsubst => 0,
);

#
# Iteration limits. The Hessenberg matrix method and the Laguerre method run
# continuously until they converge upon an answer. The iteration limits are
# there to prevent the loops from running forever if they fail to converge.
#
my %iteration = (
	hessenberg => 60,
	laguerre => 60,
	sturm_bisection => 100,
);

#
# Some values here are placeholders only, and will get
# replaced in the BEGIN block.
#
my %tolerance = (
	laguerre => 1e-14,
	fltcmp => 1.5e-8,
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

	$tolerance{laguerre} = 2 * $epsilon;
}

#
# sign($x);
#
#
sub sign
{
	my($x) = @_;
	return 1 if ($x > 0);
	return -1 if ($x < 0);
	return 0;
}

#
# if (fltcmp($x, $y) == 0) { ... }
#
# Compare two floating point numbers to a certain degree of accuracy.
# Like other functions ending in "cmp", returns -1 if $x < $y, 1 if
# $x > $y, and 0 if the arguments are equal, the difference being that
# the comparisons are made within a tolerance set in poly_tolerance().
#
sub fltcmp
{
	my($a, $b) = @_;
	#my($flt) = 0.25/16777216;	# a good enough value for testing.

	return -1 if ($a + $tolerance{fltcmp} < $b);
	return 1 if ($a - $tolerance{fltcmp} > $b);
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
# method regardless of the degree of the polynomial.
# OBSOLETE: use poly_option() instead!
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
# poly_option(opt1 => 1, opt2 => 0, ...);
#
sub poly_option
{
	my %opts = @_;
	my %old_opts;

	return %option if (scalar @_ == 0);

	foreach my $okey (keys %opts)
	{
		#
		# If this is a real option, save its old value, then set it.
		#
		if (exists $option{$okey})
		{
			$old_opts{$okey} = $option{$okey};
			$option{$okey} = ($opts{$okey})? 1: 0;
		}
		else
		{
			carp "poly_option(): unknown key $okey.";
		}
	}

	return %old_opts;
}

#
# poly_tolerance(opt1 => n, opt2 => n, ...);
#
sub poly_tolerance
{
	my %tols = @_;
	my %old_tols;

	return %tolerance if (scalar @_ == 0);

	foreach my $k (keys %tols)
	{
		#
		# If this is a real tolerance limit, save its old value, then set it.
		#
		if (exists $tolerance{$k})
		{
			my $val = abs($tols{$k});

			$old_tols{$k} = $tolerance{$k};
			$tolerance{$k} = $val;
		}
		else
		{
			croak "poly_tolerance(): unknown key $k.";
		}
	}

	return %old_tols;
}

#
# poly_iteration(opt1 => n, opt2 => n, ...);
#
sub poly_iteration
{
	my %limits = @_;
	my %old_limits;

	return %iteration if (scalar @_ == 0);

	foreach my $k (keys %limits)
	{
		#
		# If this is a real iteration limit, save its old value, then set it.
		#
		if (exists $iteration{$k})
		{
			my $val = abs(int($limits{$k}));
			
			carp "poly_iteration(): Unreasonably small value for $k => $val\n" if ($val < 10);

			$old_limits{$k} = $iteration{$k};
			$iteration{$k} = $val;
		}
		else
		{
			croak "poly_iteration(): unknown key $k.";
		}
	}

	return %old_limits;
}

#
# @x = linear_roots($a, $b)
#
#
sub linear_roots
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
sub quadratic_roots
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
sub cubic_roots
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
sub quartic_roots
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

		#### $z

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

sub BASE ()    { 2 }
sub BASESQR () { BASE * BASE }

#
# $matrix_ref = build_companion(@coefficients);
#
# Build the Companion Matrix of the N degree polynomial.  Return a
# reference to the N by N matrix.
#
sub build_companion
{
	my @coefficients = @_;
	my $n = $#coefficients;
	my @h;			# The matrix.

	#
	### build_companion called with: @coefficients
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
	### Now we balance the matrix.
	#### @h
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
sub hqr_eigen_hessenberg
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

		while ($its < $iteration{hessenberg})
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

			croak "Too many iterations ($its) at n=$n\n" if ($its >= $iteration{hessenberg});

			if ($its && $its % 10 == 0)
			{
				#
				# Form exceptional shift.
				#
				### Exceptional shift at: $its
				#

				$t += $x;
				for my $i (1 .. $n)
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

			for my $i (($m + 2) .. $n)
			{
				$h[$i][$i - 2] = 0.0;
			}
			for my $i (($m + 3) .. $n)
			{
				$h[$i][$i - 3] = 0.0;
			}

			#
			# Double QR step involving rows $l to $n and
			# columns $m to $n.
			#
			for my $k ($m .. $na)
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
				for my $j ($k .. $n)
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
				$j = $n if ($j > $n);

				#
				# Column modification.
				#
				for my $i ($l .. $j)
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
sub poly_roots
{
	my(@coefficients) = @_;
	my(@x, @zero_x);
	my $subst_degree = 1;

	#
	#### @coefficients
	#
	# Check for zero coefficients in the higher-powered terms.
	#
	shift @coefficients while (scalar @coefficients and abs($coefficients[0]) < $epsilon);

	if (@coefficients == 0)
	{
		carp "All coefficients are zero\n";
		return (0);
	}

	#
	# How about zero coefficients in the low terms?
	#
	while (scalar @coefficients and abs($coefficients[$#coefficients]) < $epsilon)
	{
		push @zero_x, 0;
		pop @coefficients;
	}

	#
	# If the polynomial is of the form ax**n + c, and $option{root_function}
	# is set, use the Math::Complex::root() function to return the roots.
	#
	### %option
	#
	if ($option{root_function} and poly_nonzero_term_count(@coefficients) == 2)
	{
		return  @zero_x,
			root(-$coefficients[$#coefficients]/$coefficients[0], $#coefficients);
	}

	#
	# Next do some analysis of the coefficients.
	# See if we can reduce the size of the polynomial by
	# doing some variable substitution.
	#
	if ($option{varsubst})
	{
		my $cf;
		($cf, $subst_degree) = poly_analysis(@coefficients);
		@coefficients = @$cf if ($subst_degree > 1);
	}

	#
	# If the remaining polynomial is a quintic or higher, or
	# if $option{hessenberg} is set, continue with the matrix
	# calculation.
	#
	#### @coefficients
	#### $subst_degree
	#
	if ($option{hessenberg} or $#coefficients > 4)
	{
		my $matrix_ref = build_companion(@coefficients);

		#### Balanced Companion Matrix (row and column 0 will be undefs)...
		#### $matrix_ref

		#
		# QR iterations from the matrix.
		#
		@x = hqr_eigen_hessenberg($matrix_ref);
	}
	elsif ($#coefficients == 4)
	{
		@x = quartic_roots(@coefficients);
	}
	elsif ($#coefficients == 3)
	{
		@x = cubic_roots(@coefficients);
	}
	elsif ($#coefficients == 2)
	{
		@x = quadratic_roots(@coefficients);
	}
	elsif ($#coefficients == 1)
	{
		@x = linear_roots(@coefficients);
	}

	@x = map(root($_, $subst_degree), @x) if ($subst_degree > 1);

	return  @zero_x, @x;
}

#
# ($new_coefficients_ref, $varsubst) = poly_analysis(@coefficients);
#
# If the polynomial has evenly spaced gaps of zero coefficients, reduce
# the polynomial through variable substitution.
#
# For example, a degree-6 polynomial like 9x**6 + 128x**3 + 7
# can be reduced to a polynomial 9y**2 + 128y + 7, where y = x**3.
#
# After solving a quadratic instead of a sextic, the actual roots of
# the original equation are found by taking the cube roots of each
# root of the quadratic.
#
sub poly_analysis
{
	my(@coefficients) = @_;
	my @czp;
	my $m = 1;

	#
	# Is the count of coefficients a multiple of any of the primes?
	#
	# Realistically I don't expect any gaps that can't be handled by
	# the first three prime numbers, but it's not much of a waste of
	# space to go up to 31.
	#
	@czp = grep(($#coefficients % $_) == 0,
		(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31)
	);

	#
	# Any coefficients zero at the non-N degrees? (1==T,0==F).
	#
	#### @czp
	#
	if (@czp)
	{
		for my $j (0..$#coefficients)
		{
			if (abs($coefficients[$j]) > $epsilon)
			{
				@czp = grep(($j % $_) == 0, @czp);
			}
		}

		#
		# The remaining list of primes represent the gap size
		# between non-zero coefficients.
		#
		map(($m *= $_), @czp);

		### Substitution degree: $m
	}

	#
	# If there's a sequence of zero-filled gaps in the coefficients,
	# reduce the polynomial by degree $m and check again for the
	# next round of factors (e.g., X**8 + X**4 + 1 needs two rounds
	# to get to a factor of 4).
	#
	if ($m > 1)
	{
		my @alt_coefs;
		push @alt_coefs, $coefficients[$_*$m] for (0..$#coefficients/$m);
		my($cf, $m1) = poly_analysis(@alt_coefs);
		@coefficients = @$cf;
		$m *= $m1;
	}

	return \@coefficients, $m;
}

#
# $nzterms = poly_nonzero_term_count(@coeffients);
#
# Count the number of non-zero terms. Simple enough, yes?
#
sub poly_nonzero_term_count
{
	my(@coefficients) = @_;
	my $nzc = 0;

	for my $j (0..$#coefficients)
	{
		$nzc++ if (abs($coefficients[$j]) > $epsilon);
	}
	return $nzc;
}

#
# @monic_polynomial = simplified_form(@coefficients);
#
# Return polynomial without any leading zero coefficients and in
# a monic polynomial form (all coefficients divided by the coefficient
# of the highest power).
#
sub simplified_form
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
sub poly_derivative
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
sub poly_antiderivative
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
sub poly_evaluate
{
	my($coef_ref, $xval_ref) = @_;

	my @coefficients = @$coef_ref;
	my @values;

	#
	# Allow some flexibility in sending the x-values.
	#
	if (ref $xval_ref eq "ARRAY")
	{
		@values = @$xval_ref;
	}
	else
	{
		#
		# It could happen. Someone might type \$x instead of $x.
		#
		@values = ( (ref $xval_ref eq "SCALAR")? $$xval_ref: $xval_ref);
	}

	#
	# Move the leading coefficient off the polynomial list
	# and use it as our starting value(s).
	#
	my @results = (shift @coefficients) x scalar @values;

	foreach my $c (@coefficients)
	{
		foreach my $j (0..$#values)
		{
			$results[$j] = $results[$j] * $values[$j] + $c;
		}
	}

	return wantarray? @results: $results[0];
}

#
# ($q_ref, $r_ref) = poly_divide(\@coefficients1, \@coefficients2);
#
# Synthetic division for polynomials. Returns references to the quotient
# and the remainder.
#
sub poly_divide
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
sub poly_constmult
{
	my($c_ref, $multiplier) = @_;
	my @coefficients = @$c_ref;

	return map($_ *= $multiplier, @coefficients);
}

#
# @sturm_seq = poly_sturm_chain(@coefficients)
#
#
sub poly_sturm_chain
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
	#### poly_sturm_chain:
	#### @chain
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
sub poly_real_root_count
{
	my(@coefficients) = @_;

	my @chain = poly_sturm_chain(@coefficients);

	return sturm_sign_count(sturm_sign_minus_inf(\@chain)) -
		sturm_sign_count(sturm_sign_plus_inf(\@chain));
}

#
# $root_count = sturm_real_root_range_count(\@chain, $x0, $x1);
#
# An all-in-one function for finding the number of real roots in
# a polynomial. Use this if you don't intend to do anything else
# requiring the Sturm chain.
#
sub sturm_real_root_range_count
{
	my($chain_ref, $x0, $x1) = @_;

	my @signs = sturm_sign_chain($chain_ref, [$x0, $x1]);

	return sturm_sign_count(@{$signs[0]}) - sturm_sign_count(@{$signs[1]});
}

#
# @roots = sturm_bisection_roots(\@chain, $from, $to);
#
# Using the bisection method on the root count method of Sturm, finds
# the real roots of a polynomial function. Will not find complex roots.
#
sub sturm_bisection_roots
{
	my($chain_ref, $from, $to) = @_;
	my(@coefficients) = @{${$chain_ref}[0]};
	my @roots;

	#
	#### @coefficients
	#
	#
	# If we have a linear equation, just solve the thing. We're not
	# going to find a useful second derivative, after all. (Which
	# would raise the question of why we're here without a useful
	# Sturm chain, but never mind...)
	#
	if ($#coefficients == 1)
	{
		push @roots, linear_roots(@coefficients);
		return @roots;
	}

	#
	# Do Sturm bisection here.
	#
	my $range_count = sturm_real_root_range_count($chain_ref, $from, $to);

	#
	# If we're down to one root in this range, use Laguerre's method
	# to hunt it down.
	#
	if ($range_count == 1)
	{
		push @roots, laguerre(\@coefficients, ($from + $to)/2.0);
	}
	elsif ($range_count > 1)
	{
		my $its = 0;

		ROOT:
		for (;;)
		{
			my $mid = ($to + $from)/2.0;
			my $frommid_count = sturm_real_root_range_count($chain_ref, $from, $mid);
			my $midto_count = sturm_real_root_range_count($chain_ref, $mid, $to);

			#
			### $its
			### $from
			### $to
			### $mid
			### $frommid_count
			### $midto_count
			#

			#
			# Bisect again if we only narrowed down to a range
			# containing all the roots.
			#
			if ($frommid_count == 0)
			{
				$from = $mid;
			}
			elsif ($midto_count == 0)
			{
				$to = $mid;
			}
			else
			{
				#
				# We've divided the roots between two ranges. Do it
				# again until each range has a single root in it.
				#
				push @roots, sturm_bisection_roots($chain_ref, $from, $mid);
				push @roots, sturm_bisection_roots($chain_ref, $mid, $to);
				last ROOT;
			}
			croak "Too many iterations ($its) at mid=$mid\n" if ($its >= $iteration{sturm_bisection});
			$its++;
		}
	}
	return @roots;
}

#
# @signs = sturm_minus_inf(\@chain);
#
# Return an array of signs from the chain at minus infinity.
#
sub sturm_sign_minus_inf
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
sub sturm_sign_plus_inf
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
sub sturm_sign_chain
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
sub sturm_sign_count
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

sub laguerre
{
	my($p_ref, $xval_ref) = @_;
	my(@p0) = @$p_ref;
	my(@p1) = poly_derivative(@p0);
	my(@p2) = poly_derivative(@p1);
	my $n = $#p0;
	my @values;
	my @roots;

	#
	# Allow some flexibility in sending the x-values.
	#
	if (ref $xval_ref eq "ARRAY")
	{
		@values = @$xval_ref;
	}
	else
	{
		#
		# It could happen. Someone might type \$x instead of $x.
		#
		@values = ( (ref $xval_ref eq "SCALAR")? $$xval_ref: $xval_ref);
	}

	foreach my $x (@values)
	{
		my $its = 0;

		ROOT:
		for (;;)
		{
			#
			# There's a better way to do this, but
			# I'm going for "simple to code" for
			# this developer release.
			#
			my $valp0 = poly_evaluate($p_ref, $x);
			my $valp1 = poly_evaluate(\@p1, $x);
			my $valp2 = poly_evaluate(\@p2, $x);

			if (abs($valp0) <= $tolerance{laguerre})
			{
				push @roots, $x;
				last ROOT;
			}

			#
			### At Iteration: $its
			### X: $x
			### f(x): $valp0
			### f'(x): $valp1
			### f''(x): $valp2
			#
			my $g = $valp1/$valp0;
			my $h = $g * $g - $valp2/$valp0;
			my $f = sqrt(($n - 1) * ($n * $h - $g*$g));

			#
			# Divide by the largest value of $g plus
			# $f, bearing in mind that $f is the result
			# of a square root function and may be positive
			# or negative.
			#
			# Use the abs() function to determine size
			# since $g or $f may be complex numbers.
			#
			$f = - $f if (abs($g - $f) > abs($g + $f));
			my $dx = $n/($g + $f);

			$x -= $dx;
			if (abs($dx) <= $tolerance{laguerre})
			{
				push @roots, $x;
				last ROOT;
			}

			croak "Too many iterations ($its) at dx=$dx\n" if ($its >= $iteration{laguerre});
			$its++;
		}
	}
	return @roots;
}

sub poly_gcd
{
	my($c1_ref, $c2_ref) = @_;
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
  poly_option(hessenberg => 0);
  @x = poly_roots(@coefficients);

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
polynomials, along with some utility functions.

Functions making use of the Sturm sequence are also available, letting you
find the number of real roots present in a range of X values.

In addition to the root-finding functions, the internal functions have
also been exported for your use.

=head2 Numeric Functions

These are the functions that calculate the polynomial's roots through numeric
algorithms. They are all exported under the tag "numeric".

=head3 poly_roots()

Returns the roots of a polynomial equation, regardless of degree.
Unlike the other root-finding functions, it will check for coefficients
of zero for the highest power, and 'step down' the degree of the
polynomial to the appropriate case. Additionally, it will check for
coefficients of zero for the lowest power terms, and add zeros to its
root list before calling one of the root-finding functions.

By default, C<poly_roots()> will use the Hessenberg matrix method for solving
polynomials. This can be changed by calling L</poly_options()>.

=head3 get_hessenberg() I<DEPRECATED>

Returns 1 or 0 depending upon whether C<poly_roots()> always makes use of
the Hessenberg matrix method or not.

B<NOTE>: this function is replaced by the option function C<poly_option()>.

=head3 set_hessenberg() I<DEPRECATED>

Sets or removes the condition that forces the use of the Hessenberg matrix
regardless of the polynomial's degree.  A zero argument forces the
use of classical methods for polynomials of degree less than five, a
non-zero argument forces C<poly_roots()> to always use the matrix method.
The default state of the module is to always use the matrix method.
This is a complete change from the default behavior in versions less than v2.50.

B<NOTE>: this function is replaced by the option function C<poly_option()>.

=head3 poly_option()

Set options that affect the behavior of the C<poly_roots()> function. All options
are set to either 1 ("on") or 0 ("off"). See also L</poly_iteration()>
and L/<poly_tolerance()>.

This is the option function that deprecates C<set_hessenberg()> and
C<get_hessenberg()>.

Options may be set and saved:

  #
  # Set a few options...
  #
  poly_option(hessenberg => 0, root_function => 1);

  #
  # Get all of the current options and their values.
  #
  my %all_options = poly_option();

  #
  # Set some options but save the former option values
  # for later.
  #
  my %changed_options = poly_option(hessenberg => 1, varsubst => 1);

The current options available are:

=over 4

=item hessenberg

Use the QR Hessenberg matrix method to solve the polynomial. By default, this
is set to 1. If set to 0, C<poly_roots()> uses one of the L<classical|Classical Functions>
root-finding functions listed below, I<if> the degree of the polynomial is four
or less.

=item root_function

Use the L<root()|Math::Complex/OPERATIONS> function from Math::Complex if the
polynomial is of the form C<ax**n + c>. This will take precedence over the other
solving methods.

=item varsubst

Reduce polynomials to a lower degree through variable substitution, if possible.

For example, with varsubst set to one and the polynomial to solve is C<9x**6 + 128x**3 + 21>,
then C<poly_roots()> will reduce the polynomial to C<9y**2 + 128y + 21>, where y = x**3,
and solve the quadratic (either classically or numerically, depending
on the hessenberg option). Taking the cube root of each quadratic root
completes the operation.

This has the benefit of having a simpler matrix to solve, or if the hessenberg option
is set to zero, has the effect of being able to use one of the classical methods on a
polynomial of high degree. In the above example, the order-six polynomial gets solved
with the quadratic_roots() function if the hessenberg option is zero.

Currently the variable substitution is fairly simple and will only look
for gaps of zeros in the coefficients that are multiples of the prime numbers
less than or equal to 31 (2, 3, 5, et cetera).

=back

=head2 Classical Functions

These are the functions that solve polynomials via the classical methods.
Quartic, cubic, quadratic, and even linear equations may be solved with
these functions. They are all exported under the tag "classical".

L</poly_roots()> will use these functions I<if> the hessenberg option
is set to 0, I<and if> the degree of the polynomial is four or less.

The leading coefficient C<$a> must always be non-zero for the classical
functions.

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

by the method described by R. W. D. Nickalls (see the L</ACKNOWLEDGMENTS>
section below). Returns a three-element list. The first element will
always be real. The next two values will either be both real or both
complex numbers.

=head3 quartic_roots()

Gives the roots of the quartic equation

  ax**4 + bx**3 + cx**2 + dx + e = 0

using Ferrari's method (see the L</ACKNOWLEDGMENTS> section below). Returns
a four-element list. The first two elements will be either
both real or both complex. The next two elements will also be alike in
type.

=head2 Sturm Functions

These are the functions that create and make use of the Sturm sequence.
They are all exported under the tag "sturm".

=head3 poly_real_root_count()

Return the number of I<unique>, I<real> roots of the polynomial.

  $unique_roots = poly_real_root_count(@coefficients);

For example, the equation C<(x + 3)**3> forms the polynomial C<x**3 + 9x**2 + 27x + 27>,
but since all three of its roots are identical, C<poly_real_root_count(1, 9, 27, 27)> will return 1.

Likewise, C<poly_real_root_count(1, -8, 25)> will return 0 because the two roots
of C<x**2 -8x + 25> are both complex.

This function is the all-in-one function to use instead of

  my @chain = poly_sturm_chain(@coefficients);

  return sturm_sign_count(sturm_sign_minus_inf(\@chain)) -
          sturm_sign_count(sturm_sign_plus_inf(\@chain));

if you don't intend to use the Sturm chain for anything else.

=head3 poly_sturm_chain()

Returns the chain of Sturm functions used to evaluate the number of roots of a
polynomial in a range of X values.

If you feed in a sequence of X values to the Sturm functions, you can tell where
the (real, not complex) roots of the polynomial are by counting the number of
times the Y values change sign.

See L</poly_real_root_count()> above for an example of its use.

=head3 sturm_real_root_range_count()

Return the number of I<unique>, I<real> roots of the polynomial.

  my($x0, $x1) = (0, 1000);

  my @chain = poly_sturm_chain(@coefficients);
  $unique_roots = sturm_real_root_range_count(\@chain, $x0, $x1);

Internally, this is equivalent to:

  my @signs = sturm_sign_chain(\@chain, [$x0, $x1]);
  return sturm_sign_count(@{$signs[0]}) - sturm_sign_count(@{$signs[1]});

=head3 Sturm Sign Sequence Functions

=head4 sturm_sign_chain()

=head4 sturm_sign_minus_inf()

=head4 sturm_sign_plus_inf()

These functions return the array of signs that are used by the functions
L</poly_real_root_count()> and L</sturm_real_root_range_count()> to find
the number of real roots in a polynomial.

In normal use you will probably never need to use them, unless you want
to examine the internals of the Sturm functions:

  #
  # Examine the sign changes that occur at each endpoint of
  # the x range.
  #
  my(@coefficients) = (1, 4, 7, 23);
  my(@xvals) = (-12, 12);

  my @chain = poly_sturm_chain( @coefficients);
  my @signs = sturm_sign_chain(\@chain, \@xvals);  # An array of arrays.

  print "\nPolynomial: [", join(", ", @coefficients), "]\n";

  foreach my $j (0..$#signs)
  {
    my @s = @{$signs[$j]};
    print $xval[$j], "\n",
          "\t", join(", ", @s), "], sign count = ",
          sturm_sign_count(@s), "\n\n";
    }

Similar examinations can be made at plus and minus infinity:

  #
  # Examine the sign changes that occur between plus and minus
  # infinity.
  #
  my @coefficients = (1, 4, 7, 23);

  my @chain = poly_sturm_chain( @coefficients);
  my @smi = sturm_sign_minus_inf(\@chain);
  my @spi = sturm_sign_plus_inf(\@chain);

  print "\nPolynomial: [", join(", ", @coefficients), "]\n";

  print "Minus Inf:\n",
        "\t", join(", ", @smi), "], sign count = ",
        sturm_sign_count(@smi), "\n\n";

  print "Plus Inf:\n",
        "\t", join(", ", @spi), "], sign count = ",
        sturm_sign_count(@spi), "\n\n";

=head3 sturm_sign_count()

Counts and returns the number of sign changes in a sequence of signs,
such as those returned by the L</Sturm Sign Sequence Functions>

See L</poly_real_root_count()> and L</sturm_real_root_range_count()> for
examples of its use.

=head3 sturm_bisection_roots()

Return the I<real> roots counted by L</sturm_real_root_range_count()>. Uses the
bisection method combined with C<sturm_real_range_count()> to narrow the range
to a single root, then uses L</laguerre()> to find the value.

  my($from, $to) = (-1000, 0);
  my @chain = poly_sturm_chain(@coefficients);
  my @roots = sturm_bisection_roots(\@chain, $from, $to);

As it is using the Sturm functions, it will find only the real roots.

=head2 Utility Functions

These are internal functions used by the other functions listed above,
but which may also be useful to the user. They are all exported under the tag "utility".

=head3 epsilon()

Returns the machine epsilon value that was calculated when this module was loaded.

The value may be changed, although this in general is not recommended.

  my $old_epsilon = epsilon($new_epsilon);

The previous value of epsilon may be saved to be restored later.

The Wikipedia article at L<http://en.wikipedia.org/wiki/Machine_epsilon/> has
more information on the subject.

=head3 fltcmp()

Compare two floating point numbers within a degree of accuracy.

Like most functions ending in "cmp", this one returns -1 if the first
argument tests as less than the second argument, 1 if the first tests
greater than the second, and 0 otherwise. Comparisons are made within
a tolerance range that may be set with L</poly_tolerance()>.

  #
  # Set a very forgiving comparison tolerance.
  #
  poly_tolerance(fltcmp => 1e-5);
  my @x = poly_roots(@cubic);
  my @y = poly_evaluate(\@cubic, \@x);

  if (fltcmp($y[0], 0.0) == 0 and
      fltcmp($y[1], 0.0) == 0 and
      fltcmp($y[2], 0.0) == 0)
  {
    print "Roots found: (", join(", ", @x), ")\n";
  }
  else
  {
    print "Problem root-finding for [", join(", ", @cubic), "]\n";
  }

=head3 laguerre()

A numerical method for finding a root of an equation, especially made
for polynomials.

  @roots = laguerre(\@coefficients, \@xvalues);
  push @roots, laguerre(\@coefficients, $another_xvalue);

For each x value the function will attempt to find a root closest to it.

=head3 poly_iteration()

Sets the limit to the number of iterations that a solving method may go
through before giving up trying to find a root. Each method of root-finding
used by L</poly_roots()>, L</sturm_bisection_roots()>, and L</laguerre()>
has its own iteration limit, which may be found, like L</poly_option()>, by
simply looking at the return value of poly_iteration().

  #
  # Get all of the current iteration limits.
  #
  my %its_limits = poly_iteration();

  #
  # Double the limit for the hessenberg method, but set the limit
  # for Laguerre's method to 20.
  #
  poly_iteration(hessenberg => $its_limits{hessenberg} * 2, laguerre => 12);

  #
  # Reset the limits with the former values, but save the values we had
  # for later.
  #
  my %hl_limits = poly_iteration(%its_limits);

There are iteration limit values for:

=over 4

=item hessenberg

The numeric method used by poly_roots(), if the hessenberg option is set.
Its default value is 60.

=item laguerre

The numeric method used by laguerre(). Laguerre's method is used within
sturm_bisection_roots() once an individual root has been found within a
range, and of course it may be called independently. Its default value is
60.

=item sturm_bisection

The bisection method used to find roots within a range. Its default value
is 100.

=back

=head3 poly_tolerance()

Set the degree of accuracy needed for comparisons to be equal or roots to
be found.  Amongst the root finding functions this currently only
affects laguerre(), as the Hessenberg matrix method determines how close
it needs to get using a complicated formula based on L</epsilon()>.

  #
  # Print the tolerances.
  #
  my %tolerances = poly_tolerance();
  print "Default tolerances:\n";
  foreach my $k (keys %tolerances)
  {
    print "$k => ", $tolerances{$k}, "\n";
  }

  #
  # Quadruple the tolerance for Laguerre's method.
  #
  poly_tolerance(laguerre => 4 * $tolerances{laguerre});

Tolerances may be set for:

=over 4

=item laguerre

The numeric method used by laguerre(). Laguerre's method is used within
sturm_bisection_roots() once an individual root has been found within a range,
and of course it may be called independently.

=item fltcmp

A comparison function that determines if one argument is less than, equal to,
or greater than, the other. Comparisons are made within a range determined by
the tolerance.

=back

=head3 poly_derivative()

  @derivative = poly_derivative(@coefficients);

Returns the coefficients of the first derivative of the polynomial.
Leading zeros are removed before returning the derivative, so the length
of the returned polynomial may be even shorter than expected from the length of the original
polynomial. Returns an empty list if the polynomial is a simple constant.

=head3 poly_antiderivative()

Returns the coefficients of the antiderivative of the polynomial. The
constant term is set to zero; to override this use

  @integral = poly_antiderivative(@coefficients);
  $integral[$#integral] = $const_term;

=head3 simplified_form()

Return the polynomial adjusted by removing any leading zero coefficients
and placing it in a monic polynomial form (all coefficients divided by the
coefficient of the highest power).

=head3 poly_evaluate()

Returns the values of the polynomial given a list of arguments. Unlike
most of the above functions, this takes the reference of the coefficient list,
which lets the function take a single x-value or multiple x-values passed in
as a reference.

The function may return a list...

  my @coefficients = (1, -12, 0, 8, 13);
  my @xvals = (0, 1, 2, 3, 5, 7);
  my @yvals = poly_evaluate(\@coefficients, \@xvals);

  print "Polynomial: [", join(", ", @coefficients), "]\n";

  for my $j (0..$#yvals) {
    print "Evaluates at ", $xvals[$j], " to ", $yvals[$j], "\n";
  }

or return a scalar.
 
  my $x_median = ($xvals[0] + $xvals[$#xvals])/2.0;
  my $y_median = poly_evaluate(\@coefficients, $x_median);


=head3 poly_nonzero_term_count()

Returns a simple count of the number of coefficients that aren't zero.

=head3 poly_constmult()

Simple function to multiply all of the coefficients by a constant. Like
C<poly_evaluate()>, uses the reference of the coefficient list.

  my @coefficients = (1, 7, 0, 12, 19);
  my @coef3 = poly_constmult(\@coefficients, 3);

=head3 poly_divide()

Divide one polynomial by another. Like C<poly_evaluate()>, the function takes
a reference to the coefficient list. It returns a reference to both a quotient
and a remainder.

  my @coefficients = (1, -13, 59, -87);
  my @polydiv = (3, -26, 59);
  my($q, $r) = poly_divide(\@coefficients, \@polydiv);
  my @quotient = @$q;
  my @remainder = @$r;

=head1 EXPORT

There are no default exports. The functions may be individually named in an
export list, but there are also four export tags:
L<classical|Classical Functions>,
L<numeric|Numeric Functions>,
L<sturm|Sturm Functions>, and
L<utility|Utility Functions>.

=head1 ACKNOWLEDGMENTS

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

=head2 Sturm's Sequence and Laguerre's Method

D�rrie, Heinrich. I<100 Great Problems of Elementary Mathematics; Their History and Solution>.
New York: Dover Publications, 1965. Translated by David Antin.

=over 5

Discusses Charles Sturm's 1829 paper with an eye towards mathematical proof
rather than an algorithm, but is still very useful.

=back

Glassner, Andrew S. I<Graphics Gems>. Boston: Academic Press, 1990. 

=over 5

The chapter "Using Sturm Sequences to Bracket Real Roots
of Polynomial Equations" (by D. G. Hook and P. R. McAree) has a clearer
description of the actual steps needed to implement Sturm's method.

=back

Acton, Forman S. I<Numerical Methods That Work>. New York: Harper & Row, Publishers, 1970.

=over 5

Lively, opinionated book on numerical equation solving. I looked it up when it
became obvious that everyone was quoting Acton when discussing Laguerre's method.

=back

=head1 SEE ALSO

Forsythe, George E., Michael A. Malcolm, and Cleve B. Moler
I<Computer Methods for Mathematical Computations>. Prentice-Hall, 1977.

=head1 AUTHOR

John M. Gamble may be found at B<jgamble@cpan.org>

=cut
