use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'XML::RAI',
    'VERSION_FROM'	=> 'lib/XML/RAI.pm',
    'PREREQ_PM'		=> { XML::Elemental=>1.01, POSIX=>0, Date::Parse=>0 }, 
);
