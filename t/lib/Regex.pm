package Regex;

use strict;
use warnings;

sub test {
    my $test = shift;

    return $test =~ /blah/;
}

sub _fallback_string {
    my $a = shift;
    my $b = shift;

    $a ? $b =~ s{test}{}gr : q{};
}

1;
