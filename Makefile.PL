use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'XML::RAI',
    'VERSION_FROM'	=> 'lib/XML/RAI.pm', # finds $VERSION
    'PREREQ_PM'		=> { XML::RSS::Parser=>2.1, POSIX, Date::Parse }, # e.g., Module::Name => 1.1
);
