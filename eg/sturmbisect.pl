#!/bin/perl
#
use Carp;
use Getopt::Long;
use Math::Polynomial::Solve qw(:sturm :utility ascending_order);
use Math::Complex;
use strict;
use warnings;
#use IO::Prompt;

my $line;
my $ascending = 0;

GetOptions('ascending' => \$ascending);

ascending_order($ascending);

while ($line = prompt("Polynomial: ", -num))
{
	my @coef = split(/,? /, $line);
	my @chain = poly_sturm_chain( @coef );

	$line = prompt("Two X values: ");
	my @xvals = split(/,? /, $line);

	croak "Only two x values please" if (scalar @xvals != 2);

	print "\nPolynomial: [", join(", ", @coef), "]\n";

	my @roots = sturm_bisection_roots(\@chain, $xvals[0], $xvals[1]);
	my @zeros = poly_evaluate(\@coef, \@roots);

	my $c = 0;
	$c += abs(fltcmp($_, 0.0)) foreach(@zeros);
	print "zeros at: [", join(", ", @roots), "]\n\n";
	print "$c non-roots\n" if ($c);
}

exit(0);

sub prompt
{
	my $pr = shift;
	print $pr;
	my $inp = <>;
	chomp $inp;
	return $inp;
}

