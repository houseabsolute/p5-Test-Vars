#!perl -w

use strict;
use Test::More;

use Test::Vars;

vars_ok('lib/Test/Vars.pm');
vars_ok('Test::Vars');
vars_ok('lib/Test/Vars.pm', ignore_vars => { '$self' => 1 });

TODO: {
    local $TODO = 'https://github.com/houseabsolute/p5-Test-Vars/issues/43';
    vars_ok( 't/lib/FinalVar.pm' );
}

done_testing;
