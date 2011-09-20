use Module::Build;
use strict;
use warnings;

my $build = Module::Build->new(
	abstract => 'Find the Roots of Polynomial Equations',
	author => 'John M. Gamble <jgamble@cpan.org>',
	name => 'Math::Polynomial::Solve',
	version => 'lib/Math/Polynomial/Solve.pm',
	release_status => 'testing',
	license => ['perl_5'],

	prereqs => {
		runtime => {
			requires => {
				perl=> '5.008',
				'Math::Complex'=> '1.36',  # Bugfix of Im().
			},
		},

		test => {
			requires => {
				'Test::Simple' => 0
			},
	},
	resources => {
		repository => {
			url => 'git://github.com/jgamble/Math-Polynomial-Solve.git',
			web => 'https://github.com/jgamble/Math-Polynomial-Solve',
			type => 'git',
		}
	},

	dynamic_config => 0,
	create_readme => 0,
	create_makefile_pl => 'traditional',

	keywords => [ qw(math polynomial solve roots
				quadratic cubic quartic matrix
				derivative antiderivative Nickalls Ferrari
				Laguerre Newton-Raphson Sturm Hessenberg
			) ],

	meta_spec => {
		version => x.xx,
	},
);

$build->create_build_script;
