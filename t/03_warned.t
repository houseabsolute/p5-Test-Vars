#!perl

use strict;
use warnings;

use File::Basename qw(basename);
use Test::Tester;
use Test::More;

use Test::Vars;

my %errors = (
    Warned1 => [ [ '$an_unused_var', 'foo', 6 ] ],
    Warned2 => [ [ '@an_unused_var', 'foo', 6 ] ],
    Warned3 => [ [ '%an_unused_var', 'foo', 6 ] ],
    Warned4 => [ [ '$an_unused_var', 'foo', 6 ] ],
    Warned5 => [
        [ '$unused_var', 'foo', 6 ],
        [ '$unused_var', 'foo', 6 ],
    ],
    Warned6 => [ [ '$unused_param', 'foo', 6 ] ],

    # The diag output from Warned7 is not in a predictable order, so we have
    # to ignore it.
    Warned7 => [
        [ '$unused_var', 'foo', 6 ],
        [ '$unused_var', 'bar', 13 ],
    ],
);

foreach my $package ( sort keys %errors ) {
    my $errors = $errors{$package};
    my $file   = "$package.pm";
    my $path   = "t/lib/$file";

    my ( $premature, @results ) = run_tests( sub { vars_ok($path) } );
    ok( !$premature, "var_ok($path) had no premature output" );
    is( scalar @results, 1, "got one result from vars_ok($path)" );
    is(
        $results[0]{fail_diag}, "\tFailed test (t/03_warned.t at line 36)\n",
        'failure message comes from inside this test file'
    );

    if ( @{$errors} == 1 ) {
        is(
            $results[0]{diag},
            _error( @{ $errors->[0] }, $package, $path ),
            "expected diag() from vars_ok($path)"
        );
    }
    else {
        my @errors = map { _error( @{$_}, $package, $path ) } @{$errors};
        my $order1 = join q{}, @errors;
        my $order2 = join q{}, @errors[ 1, 0 ];
        like(
            $results[0]{diag},
            qr/\Q$order1\E|\Q$order2/,
            "expected diag() from vars_ok($path)"
        );
    }
}

sub _error {
    my ( $var, $sub, $line, $package, $path ) = @_;

    return "$var is used once in &${package}::$sub at $path line $line\n";
}

done_testing;
