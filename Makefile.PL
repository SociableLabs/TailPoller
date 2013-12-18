use 5.0;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'SociableLabs::TailPoller',
    VERSION_FROM      => 'lib/SociableLabs/TailPoller.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    EXE_FILES         => [
                            'scripts/tail-recent',
                         ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/SociableLabs/TailPoller.pm', # retrieve abstract from module
       AUTHOR         => 'Ross Del Duca <delducra@apple.com>') : ()),
);
