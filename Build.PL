use Module::Build;
use strict;
use warnings;

my $build = Module::Build->new(
	module_name => 'Math::Polynomial::Solve',

	dist_abstract => 'Find the Roots of Polynomial Equations',
	dist_author => ['John M. Gamble <jgamble@cpan.org>'],
	dist_version => '2.70',
	dist_name => 'Math-Polynomial-Solve',

	requires => {
		perl=> '5.10.1',
		'Math::Complex'=> '1.36',  # Bugfix of Im().
		'Math::Utils' => '1.00',
	},

	configure_requires => {
		'Module::Build' => '0.4',
	},

	build_requires => {
		'Test::Simple' => 0
	},

	license => 'perl',
	create_license => 1,
	create_readme => 0,
	create_makefile_pl => 'traditional',
	dynamic_config =>0,

	meta_merge => {
		keyword => [ qw(math polynomial quadratic cubic quartic matrix
				companion-matrix
			        Sturm Nickalls Ferrari Laguerre Hessenberg
				Newton-Raphson) ],
		resources => {
			repository => 'git://github.com/jgamble/Math-Polynomial-Solve.git',
		},
	},

);

$build->create_build_script;
