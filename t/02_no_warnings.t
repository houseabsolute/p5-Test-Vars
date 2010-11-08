#!perl -w

use strict;
use Test::More;

use Test::Vars;

my @libs =  qw(
    NoWarnings NoWarningsOnce NotWarned
    Aelemfast Closure OurVars
    StringyEval OptimizedAway Self
    Foreach
    CompileError
    ImplicitTopic
);

foreach my $lib(@libs) {
    vars_ok("t/lib/$lib.pm");

    ok !exists $INC{"t/lib/$lib.pm"}, 'library is not loaded';
}

done_testing;
