use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Math::Polynomial::Solve',
    'VERSION_FROM'	=> 'Solve.pm',	# finds $VERSION.
    'ABSTRACT_FROM'	=> 'Solve.pm',	# find the one-liner.
    'AUTHOR'		=> 'John M. Gamble (jgamble@ripco.com)',
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
);
