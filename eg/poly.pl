#!/bin/perl
#
#
#
#
use Math::Polynomial::Solve qw(poly_roots set_hessenberg);
use Math::Complex;
use Getopt::Long;

my $hess = 0;

GetOptions("hess" => \$hess,
);

set_hessenberg($hess);

my @x = poly_roots(@ARGV);
print rootformat(@x), "\n";
exit(0);

sub cartesian_format($$@)
{
	my($fmt_re, $fmt_im, @numbers) = @_;
	my(@cfn, $n, $r, $i);

	$fmt_re ||= "%.15g";		# Provide a default real format
	$fmt_im ||= " + %.15gi";	# Provide a default im format

	foreach $n (@numbers)
	{
		#
		# Is the number part of the Complex package?
		#
		if (ref($n) eq "Math::Complex")
		{
			$r = sprintf($fmt_re, Re($n));
			$i = sprintf($fmt_im, Im($n));
		}
		else
		{
			$r = sprintf($fmt_re, $n);
			$i = sprintf($fmt_im, 0);
		}

		push @cfn, $r . $i;
	}

	return wantarray? @cfn: $cfn[0];
}

sub rootformat
{
	my @fmtlist;
	foreach (@_)
	{
		push @fmtlist, cartesian_format(undef, undef, $_);
	}
	return "[ " . join(", ", @fmtlist) . " ]";
}

