# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl limit.t'

use Test::Simple tests => 7;

use Math::Polynomial::Solve qw(:utility);
use strict;
use warnings;
require "t/coef.pl";

my @options = qw( hessenberg laguerre sturm_bisection);
my %okeys = poly_iteration();
my $keystr = join(" ", sort keys %okeys);

ok( $keystr eq join(" ", sort @options),
	"Mis-matched keys, expected '$keystr'");

poly_iteration(hessenberg => 200);
%okeys = poly_iteration();
my $val = $okeys{hessenberg};
ok($val == 200, "hessenberg option is '$val' didn't get set");

poly_iteration(laguerre => 25);
%okeys = poly_iteration();
$val = $okeys{laguerre};
ok($okeys{laguerre} == 25, "laguerre option is '$val' didn't get set");

poly_iteration(sturm_bisection => 30);
%okeys = poly_iteration();
$val = $okeys{sturm_bisection};
ok($okeys{sturm_bisection} == 30, "sturm_bisection option is '$val' didn't get set");

poly_iteration(hessenberg => 60);
%okeys = poly_iteration();
$val = $okeys{hessenberg};
ok($okeys{hessenberg} == 60, "hessenberg option is '$val' didn't get set");

poly_iteration(laguerre => 65);
%okeys = poly_iteration();
$val = $okeys{laguerre};
ok($okeys{laguerre} == 65, "laguerre option is '$val' didn't get set");

poly_iteration(sturm_bisection => 70);
%okeys = poly_iteration();
$val = $okeys{sturm_bisection};
ok($okeys{sturm_bisection} == 70, "sturm_bisection option is '$val' didn't get set");


exit(0);
