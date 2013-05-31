package Test::Vars;
use 5.010_000;
use strict;
use warnings;

our $VERSION = '0.005';

our @EXPORT = qw(all_vars_ok vars_ok);

use parent qw(Test::Builder::Module);

use B ();
use ExtUtils::Manifest qw(maniread);
use Symbol qw(qualify_to_ref);

use constant _VERBOSE       => ($ENV{TEST_VERBOSE} || 0);
use constant _OPpLVAL_INTRO => 128;

#use Devel::Peek;
#use Data::Dumper;
#$Data::Dumper::Indent = 1;

sub all_vars_ok {
    my(%args) = @_;

    my $builder = __PACKAGE__->builder;

    if(not -f $ExtUtils::Manifest::MANIFEST){
        $builder->plan(skip_all => "No $ExtUtils::Manifest::MANIFEST ready");
    }
    my $manifest = maniread();
    my @libs    = grep{ m{\A lib/ .* [.]pm \z}xms } keys %{$manifest};

    if (! @libs) {
        $builder->plan(skip_all => "not lib/");
    }

    $builder->plan(tests => scalar @libs);

    my $fail = 0;
    foreach my $lib(@libs){
        _vars_ok($builder, $lib, \%args) or $fail++;
    }

    return $fail == 0;
}

sub vars_ok {
    my($lib, %args) = @_;
    return _vars_ok(__PACKAGE__->builder, $lib, \%args);
}

sub _vars_ok {
    my($builder, $file, $args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if(defined $pid){
        if($pid != 0) { # self
            waitpid $pid, 0;

            return $builder->ok($? == 0, $file);
        }
        else { # child
            exit !_check_vars($builder, $file, $args);
        }
    }
    else {
        die "fork failed: $!";
    }
}

sub _check_vars {
    my($builder, $file, $args) = @_;
    my $package = $file;

    if($file =~ /\./){ # $package seems a file
        $package =~ s{\A .* \b lib/ }{}xms;
        $package =~ s{[.]pm \z}{}xms;
        $package =~ s{/}{::}g;
    }
    else{ # $file seems a file
        $file .= '.pm';
        $file =~ s{::}{/}g;
    }

    if(ref $args->{ignore_vars} eq 'ARRAY'){
        $args->{ignore_vars} = { map{ $_ => 1 } @{$args->{ignore_vars}} };
    }

    if(not exists $args->{ignore_vars}{'$self'}){
        $args->{ignore_vars}{'$self'}++;
    }

    # ensure library loaded
    {
        local $SIG{__WARN__} = sub{ }; # ignore warnings

        # set PERLDB flags; see also perlvar
        local $^P = $^P | 0x200; # NAMEANON

        local @INC = @INC;
        if($file =~ s{\A (.*\b lib)/}{}xms){
            unshift @INC, $1;
        }
        eval { require $file };

        if($@){
            $@ =~ s/\n .*//xms;
            $builder->diag("Test::Vars ignores $file because: $@");
            return 1;
        }
    }

    $builder->note("checking $package in $file ...") if _VERBOSE;
    return _check_into_stash($builder,
        *{qualify_to_ref('', $package)}{HASH}, $file, $args);
}

sub _check_into_stash {
    my($builder, $stash, $file, $args) = @_;
    my $fail = 0;

    while(my $key = each %{$stash}){
        my $ref = \$stash->{$key};

        next if ref($ref) ne 'GLOB';

        my $gv = B::svref_2object($ref);

        my $hashref = *{$ref}{HASH};
        my $coderef = *{$ref}{CODE};

        if(($hashref || $coderef) && $gv->FILE =~ /\Q$file\E\z/xms){
            if($hashref && B::svref_2object($hashref)->NAME){ # stash
                if(not _check_into_stash($builder, $hashref, $file, $args)){
                    $fail++;
                }
            }
            elsif($coderef){
                if(not _check_into_code($builder, $coderef, $args)){
                    $fail++;
                }
            }
        }
    }

    return $fail == 0;
}

sub _check_into_code {
    my($builder, $coderef, $args) = @_;

    my $cv = B::svref_2object($coderef);

    if($cv->XSUB){
        return 1;
    }

    my %info;
    _count_padvars($cv, \%info);

    my $fail = 0;

    while(my(undef, $cv_info) = each %info){
        my $pad = $cv_info->{pad};

        $builder->note("looking into $cv_info->{name}") if _VERBOSE > 1;

        foreach my $p(@{$pad}){
            next if !( defined $p && !$p->{outside} );

            if(! $p->{count}){
                next if $args->{ignore_vars}{$p->{name}};

                if(my $cb = $args->{ignore_if}){
                    local $_ = $p->{name};
                    next if $cb->($_);
                }

                my $c = $p->{context} || '';
                $builder->diag("$p->{name} is used once in $cv_info->{name} $c");
                $fail++;
            }
            elsif(_VERBOSE > 1){
                $builder->note("$p->{name} is used $p->{count} times");
            }
        }
    }

    return $fail == 0;

}

my @padops;
my $op_anoncode;
my $op_enteriter;
my $op_entereval; # string eval
my @op_svusers;
BEGIN{
    foreach my $op(qw(padsv padav padhv)){
        $padops[B::opnumber($op)]++;
    }
    # blead commit 93bad3fd55489cbd split aelemfast into two ops.
    # Prior to that, 'aelemfast' handled lexicals too.
    my $aelemfast = B::opnumber('aelemfast_lex');
    $padops[$aelemfast == -1 ? B::opnumber('aelemfast') : $aelemfast]++;

    $op_anoncode = B::opnumber('anoncode');
    $padops[$op_anoncode]++;

    $op_enteriter = B::opnumber('enteriter');
    $padops[$op_enteriter]++;

    $op_entereval = B::opnumber('entereval');
    $padops[$op_entereval]++;

    foreach my $op(qw(srefgen refgen sassign aassign)){
        $op_svusers[B::opnumber($op)]++;
    }
}

sub _count_padvars {
    my($cv, $global_info) = @_;

    my %info;

    my $padlist  = $cv->PADLIST;

    my $padvars  = $padlist->ARRAYelt(1);

    my @pad;
    my $ix = 0;
    foreach my $padname($padlist->ARRAYelt(0)->ARRAY){
        if($padname->can('PVX')){
            my $pv = $padname->PVX;

            if($pv ne '&' && !($padname->FLAGS & B::SVpad_OUR)){
                my %p;

                $p{name}    = $pv;
                $p{outside} = $padname->FLAGS & B::SVf_FAKE ? 1 : 0;
                if($p{outside}){
                    $p{outside_padix} = $padname->PARENT_PAD_INDEX;
                }
                $p{padix} = $ix;

                $pad[$ix] = \%p;
            }
        }
        $ix++;
    }

    my $cop;

    local *B::COP::_scan_unused_vars;
    *B::COP::_scan_unused_vars = sub{
        ($cop) = @_;
    };

    my $stringy_eval_seen = 0;

    local *B::OP::_scan_unused_vars;
    *B::OP::_scan_unused_vars = sub {
        my($op) = @_;

        return if $stringy_eval_seen;

        my $optype = $op->type;
        return if !defined $padops[ $optype ];

        # stringy eval could refer all the my variables
        if($optype == $op_entereval){
            foreach my $p(@pad){
                $p->{count}++;
            }
            $stringy_eval_seen = 1;
            return;
        }

        my $targ = $op->targ;
        return if $targ == 0; # maybe foreach (...)

        my $p = $pad[$targ];

        $p->{count} ||= 0;

        if($optype == $op_anoncode){
            my $anon_cv = $padvars->ARRAYelt($targ);
            if($anon_cv->CvFLAGS & B::CVf_CLONE){
                my $my_info = _count_padvars($anon_cv, $global_info);

                $my_info->{outside} = \%info;

                foreach my $p(@{$my_info->{pad}}){
                    if(defined $p && $p->{outside_padix}){
                        $pad[ $p->{outside_padix} ]{count}++;
                    }
                }
            }
            return;
        }
        elsif($optype == $op_enteriter or ($op->flags & B::OPf_WANT) == B::OPf_WANT_VOID){
            # if $op is in void context, it is considered "not used"

            if(_ckwarn_once($cop)){
                $p->{context} = sprintf 'at %s line %d', $cop->file, $cop->line;
                return; # skip
            }
        }
        elsif($op->private & _OPpLVAL_INTRO){
            # my($var) = @_;
            #    ^^^^     padsv/non-void context
            #          ^  sassign/void context
            for(my $o = $op->next; ${$o} && ref($o) ne 'B::COP'; $o = $o->next){
                next if !$op_svusers[ $o->type ];
                next if( ($o->flags & B::OPf_WANT ) != B::OPf_WANT_VOID );

                if(_ckwarn_once($cop)){
                    $p->{context} = sprintf 'at %s line %d',
                        $cop->file, $cop->line;
                    return; # unused, but ok
                }
            }
        }

        $p->{count}++;
    }; # end _scan_unused_vars()

    my $name = sprintf('&%s::%s', $cv->GV->STASH->NAME, $cv->GV->NAME);

    my $root = $cv->ROOT;
    if(${$root}){
        B::walkoptree($root, '_scan_unused_vars');
    }
    else{
        __PACKAGE__->builder->note("NULL body subroutine $name found");
    }

    %info = (
        pad  => \@pad,
        name => $name,
    );

    return $global_info->{ ${$cv} } = \%info;
}

sub _ckwarn_once {
    my($cop) = @_;

    my $w = $cop->warnings;
    if(ref($w) eq 'B::SPECIAL'){
        return $B::specialsv_name[ ${$w} ] !~ /WARN_NONE/;
    }
    else {
        my $bits = ${$w->object_2svref};
        # see warnings::__chk() and warnings::enabled()
        return vec($bits, $warnings::Offsets{once}, 1);
    }
}

1;
__END__

=head1 NAME

Test::Vars - Detects unused variables

=head1 VERSION

This document describes Test::Vars version 0.005.

=head1 SYNOPSIS

    use Test::Vars;

    all_vars_ok(); # check libs in MANIFEST

=head1 DESCRIPTION

Test::Vars finds unused variables in order to keep the source code tidy.

=head1 INTERFACE

=head2 Exported

=head3 all_vars_ok(%args)

Tests libraries in your distribution with I<%args>.

I<libraries> are collected from the F<MANIFEST> file.

If you want to ignore variables, for example C<$foo>, you can
tell it to the test routines:

=over 4

=item C<< ignore_vars => { '$foo' => 1 } >>

=item C<< ignore_vars => [qw($foo)] >>

=item C<< ignore_if => sub{ $_ eq '$foo' } >>

=back

Note that C<$self> will be ignored by default unless you pass
explicitly C<< { '$self' => 0 } >> to C<ignore_vars>.

=head3 vars_ok($lib, %args)

Tests I<$lib> with I<%args>.

See C<all_vars_ok>.

=head1 MECHANISM

C<Test::Vars> is similar to a part of C<Test::Perl::Critic>,but the mechanism
is different.

While C<Perl::Critic>, the backend of C<Test::Perl::Critic>, scans the source
code as texts, this modules scans the compiled opcode (or AST: abstract syntax
tree) using the C<B> module. See also C<B> and its submodules.

=head1 CONFIGURATION

C<TEST_VERBOSE = 1 | 2 > shows the way this module works.

=head1 CAVEATS

https://rt.cpan.org/Ticket/Display.html?id=60018

https://rt.cpan.org/Ticket/Display.html?id=82411

=head1 DEPENDENCIES

Perl 5.10.0 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<Perl::Critic>

L<warnings::unused>

L<B>

L<Test::Builder::Module>

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, Goro Fuji (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See L<perlartistic> for details.

=cut
