use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    ABSTRACT            => 'Detects unused variables in perl modules',
    AUTHOR              => 'Goru Fuji (gfuji@cpan.org)',
    BUILD_REQUIRES      => {
        "B" => "0",
        "IO::Pipe" => "0",
        "List::Util" => "1.33",
        "parent" => "0",
        "Storable" => "0",
        "Symbol" => "0",
    },
    CONFIGURE_REQUIRES => {
        "ExtUtils::MakeMaker" => 0
    },
    DISTNAME => "Test-Vars",
    INSTALLDIRS         => ($] < 5.011 ? 'perl' : 'site'),
    LICENSE => "perl_5",
    MIN_PERL_VERSION => "5.010",
    NAME                => 'Test::Vars',
    TEST_REQUIRES => {
        "Moose::Role" => "0",
        "Test::More" => "0.88",
        "Test::Output" => "0",
        "Test::Tester" => "0"
    },
    VERSION_FROM        => 'lib/Test/Vars.pm',

    ( eval { ExtUtils::MakeMaker->VERSION(6.46) } ? () : (
        META_MERGE => {
           "dynamic_config" => 0,
           "meta-spec" => {
              "url" => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
              "version" => 2
           },
           "no_index" => {
              "directory" => [
                 "example",
                 "t",
                 "xt",
              ]
           },
           "prereqs" => {
              "develop" => {
                 "requires" => {
                    "Pod::Spelling" => "0",
                    "Test::Pod" => "1.41",
                    "Test::Pod::Coverage" => "1.04",
                    "Test::Spelling" => "0.12",
                    "Test::Synopsis" => "0"
                 }
              },
           },
           "release_status" => "unstable",
           "resources" => {
              "bugtracker" => {
                 "web" => "https://github.com/houseabsolute/p5-Test-Vars/issues"
              },
              "homepage" => "https://github.com/houseabsolute/p5-Test-Vars",
              "repository" => {
                 "type" => "git",
                 "url" => "https://github.com/houseabsolute/p5-Test-Vars.git",
                 "web" => "https://github.com/houseabsolute/p5-Test-Vars"
              }
           },
           "version" => "0.015_001",
           "x_contributors" => [
              'Dave Rolsky <autarch@urth.org>',
              'Dmitry Matrosov <amidos@amidos.ru>',
              'FUJI Goro <gfuji@cpan.org>',
              'FUJI Goro <gfx@users.noreply.github.com>',
              'FUJI Goro <goro.fuji@ebookjapan.co.jp>',
              'Fuji, Goro <g.psy.va@gmail.com>',
              'Gregory Oschwald <goschwald@maxmind.com>',
              'James E Keenan <jkeenan@cpan.org>',
              'Michael G. Schwern <schwern@pobox.com>',
              'Nicholas Clark <nick@ccl4.org>',
              'Olivier Mengué <dolmen@cpan.org>',
              'Ran Eilam <ran.eilam@gmail.com>',
              'Richard Leach <richardleach@users.noreply.github.com>',
              'cpansprout <cpansprout@gmail.com>'
           ],
           "x_serialization_backend" => "JSON::PP version 4.16",
           "x_static_install" => 1,
        },
    )),
); # END %WriteMakefileArgs

my %FallbackPrereqs = (
    "B" => "0",
    "ExtUtils::MakeMaker" => 0,
    "IO::Pipe" => "0",
    "List::Util" => "1.33",
    "parent" => "0",
    "Storable" => "0",
    "Symbol" => "0",
    "Test::More" => "0.88",
    "Test::Output" => "0",
    "Test::Tester" => "0",
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
