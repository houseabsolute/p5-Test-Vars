#!perl -w

use strict;
use Test::More;

use Test::Vars;

vars_ok('lib/Test/Vars.pm');
vars_ok('Test::Vars');
vars_ok('lib/Test/Vars.pm', ignore_vars => { '$self' => 1 });

done_testing;
