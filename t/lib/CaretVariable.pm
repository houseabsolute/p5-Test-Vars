package Foo;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(detect_os);

sub detect_os {
    if ($^O eq 'linux') {
        print "linux\n";
    }
    elsif (${^O} eq 'freebsd') {
        print "freebsd\n";
    }
    else {
        print "neither linux nor freebsd\n";
    }
}

1;
