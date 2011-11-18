use Module::Build;
use strict;
use warnings;

my $build = Module::Build->new(
	module_name => 'Math::Polynomial::Solve',

	dist_abstract => 'Find the Roots of Polynomial Equations',
	dist_author => ['John M. Gamble <jgamble@cpan.org>'],
	dist_version => '2.62_2',  
	dist_name => 'Math-Polynomial-Solve',

	requires => {
		perl=> '5.8.3',
		'Math::Complex'=> '1.36',  # Bugfix of Im().
	},

	configure_requires => {
		'Module::Build' => '0.3624',
	},

	build_requires => {
		'Test::Simple' => 0
	},

	license => 'perl',
	create_readme => 0,
	create_makefile_pl => 'traditional',
	meta_merge => {
		keyword => [ qw(math polynomial quadratic cubic quartic matrix
			        Sturm Nickalls Ferrari Laguerre Hessenberg) ],
		resources => {
			repository => 'git://github.com/jgamble/Math-Polynomial-Solve.git',
#			repository => {
#				url => 'git://github.com/jgamble/Math-Polynomial-Solve.git',
#				web => 'https://github.com/jgamble/Math-Polynomial-Solve',
#				type => 'git',
#			},
		},
	},

);

$build->create_build_script;
