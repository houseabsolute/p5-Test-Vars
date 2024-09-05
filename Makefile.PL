use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME                => 'Test::Vars',
    VERSION_FROM        => 'lib/Test/Vars.pm',
    AUTHOR              => 'Goru Fuji (gfuji@cpan.org)',
    ABSTRACT            => 'Detects unused variables in perl modules',
    INSTALLDIRS         => ($] < 5.011 ? 'perl' : 'site'),
    PREREQ_PM           => {
        'Test::Simple' => 0.44,
    },
    ( eval { ExtUtils::MakeMaker->VERSION(6.46) } ? () : ( META_MERGE => {
       "abstract" => "Detects unused variables in perl modules",
       "author" => [
          "Goro Fuji (gfx) <gfuji(at)cpan.org>"
       ],
       "dynamic_config" => 0,
       "generated_by" => "",
       "license" => [
          "perl_5"
       ],
       "meta-spec" => {
          "url" => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
          "version" => 2
       },
       "name" => "Test-Vars",
       "no_index" => {
          "directory" => [
             "t",
             "xt",
             "inc",
             "share",
             "eg",
             "examples",
             "author",
             "builder"
          ]
       },
       "prereqs" => {
          "build" => {
             "requires" => {
                "ExtUtils::MakeMaker" => "0"
             }
          },
          "configure" => {
             "requires" => {
                "ExtUtils::MakeMaker" => "0"
             }
          },
          "develop" => {
             "requires" => {
                "Pod::Spelling" => "0",
                "Test::Pod" => "1.41",
                "Test::Pod::Coverage" => "1.04",
                "Test::Spelling" => "0.12",
                "Test::Synopsis" => "0"
             }
          },
          "runtime" => {
             "requires" => {
                "B" => "0",
                "List::Util" => "1.33",
                "parent" => "0",
                "perl" => "5.010000"
             }
          },
          "test" => {
             "requires" => {
                "Moose::Role" => "0",
                "Test::More" => "0.88",
                "Test::Output" => "0",
                "Test::Tester" => "0"
             }
          }
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
       "x_static_install" => 1
    })),
);

WriteMakefile(%WriteMakefileArgs);
