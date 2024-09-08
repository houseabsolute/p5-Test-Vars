#!perl -w

use strict;
use Test::More;

use Test::Vars;

vars_ok('lib/Test/Vars.pm');
vars_ok('Test::Vars');

done_testing;
