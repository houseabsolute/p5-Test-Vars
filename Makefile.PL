use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/Test/Vars.pm';

requires 'B';
requires 'parent';

test_requires 'Test::More' => 0.88; # done_testing()

tests_recursive 't';

#auto_set_repository() if -d '.git';

clean_files qw(
    Test-Vars-* *.stackdump
    cover_db
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
