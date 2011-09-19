use Module::Build;
use strict;
use warnings;

my $build = Module::Build->new(
	module_name => 'Math::Polynomial::Solve',
	abstract => 'Find the Roots of Polynomial Equations',
	dist_author => 'John M. Gamble <jgamble@cpan.org>',
	dist_version_from => 'lib/Math/Polynomial/Solve.pm',  

	requires => {
		perl=> '5.6.0',
		'Math::Complex'=> '1.36',  # Bugfix of Im().
	},

	build_requires => { 'Test::Simple' => 0 },

	license => 'perl',
	create_readme => 0,
	create_makefile_pl => 'traditional',
	meta_merge => {
		keyword => [ qw(math polynomial solve roots
				quadratic cubic quartic matrix
				derivative antiderivative Nickalls Ferrari
				Laguerre Newton-Raphson Sturm Hessenberg
			) ],
	},
);

$build->create_build_script;
