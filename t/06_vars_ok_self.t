#!perl -w

use strict;
use Test::More;
use Test::Vars;
use File::Spec::Functions qw( catfile );

my $file;

$file = catfile( qw( lib Test Vars.pm ) );
vars_ok($file);
vars_ok('Test::Vars');
vars_ok($file, ignore_vars => { '$self' => 1 });

# https://github.com/houseabsolute/p5-Test-Vars/issues/18
$file = catfile( qw( t lib CaretVariable.pm ) );
vars_ok($file);

done_testing;
