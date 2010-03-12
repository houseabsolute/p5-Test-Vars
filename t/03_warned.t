#!perl

use strict;
use warnings;

use Test::More;
use Test::Builder::Tester;

use Test::Vars;

foreach my $lib(map{ "t/lib/Warned$_.pm" } 1 .. 7){
    test_out "not ok 1 - $lib";
    test_fail +1;
    vars_ok($lib);

    test_test "testing vars_ok($lib)";

}

done_testing;
