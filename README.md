# NAME

Test::Vars - Detects unused variables

# VERSION

This document describes Test::Vars version 0.005.

# SYNOPSIS

    use Test::Vars;

    all_vars_ok(); # check libs in MANIFEST

# DESCRIPTION

Test::Vars finds unused variables in order to keep the source code tidy.

# INTERFACE

## Exported

### all\_vars\_ok(%args)

Tests libraries in your distribution with _%args_.

_libraries_ are collected from the `MANIFEST` file.

If you want to ignore variables, for example `$foo`, you can
tell it to the test routines:

- `ignore_vars => { '$foo' => 1 }`
- `ignore_vars => [qw($foo)]`
- `ignore_if => sub{ $_ eq '$foo' }`

Note that `$self` will be ignored by default unless you pass
explicitly `{ '$self' => 0 }` to `ignore_vars`.

### vars\_ok($lib, %args)

Tests _$lib_ with _%args_.

See `all_vars_ok`.

# MECHANISM

`Test::Vars` is similar to a part of `Test::Perl::Critic`,but the mechanism
is different.

While `Perl::Critic`, the backend of `Test::Perl::Critic`, scans the source
code as texts, this modules scans the compiled opcode (or AST: abstract syntax
tree) using the `B` module. See also `B` and its submodules.

# CONFIGURATION

`TEST_VERBOSE = 1 | 2 ` shows the way this module works.

# CAVEATS

https://rt.cpan.org/Ticket/Display.html?id=60018

https://rt.cpan.org/Ticket/Display.html?id=82411

# DEPENDENCIES

Perl 5.10.0 or later.

# BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

# SEE ALSO

[Perl::Critic](http://search.cpan.org/perldoc?Perl::Critic)

[warnings::unused](http://search.cpan.org/perldoc?warnings::unused)

[B](http://search.cpan.org/perldoc?B)

[Test::Builder::Module](http://search.cpan.org/perldoc?Test::Builder::Module)

# AUTHOR

Goro Fuji (gfx) <gfuji(at)cpan.org>

# LICENSE AND COPYRIGHT

Copyright (c) 2010, Goro Fuji (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See [perlartistic](http://search.cpan.org/perldoc?perlartistic) for details.
