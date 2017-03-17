#!perl -w

use strict;
use Test::More;

use Test::Vars;

unless ( eval { require Test::Output; Test::Output->import; 1 } ) {
    plan skip_all => 'This test requires Test::Output';
}

stderr_is(
    sub { vars_ok('t/lib/UndefAuxList.pm'); },
    q{},
    'no warning from 5.22 & 5.24 bug with multideref aux_list'
);

done_testing;
