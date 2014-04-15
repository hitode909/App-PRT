package t::test;

use strict;
use warnings;
use utf8;

use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

use FindBin;
use File::Spec::Functions qw/catfile/;
use File::Temp qw(tempdir);
use File::Copy::Recursive;

# use Exporter::Lite ();

our @EXPORT = qw(
    create_hello_world
);

sub import {
    my ($class) = @_;

    strict->import;
    utf8->import;
    warnings->import;

    my ($package, $file) = caller;

    my $code = qq[
        package $package;
        use strict;
        use warnings;
        use utf8;

        use parent qw(Test::Class);
        use Test::More;
        use Test::Fatal;
        use Test::Deep;
        use Test::Mock::Guard;

        use Path::Class;

        END { $package->runtests }
    ];

    eval $code;
    die $@ if $@;
}

sub prepare_test_code {
    my ($name) = @_;

    my $base_directory = catfile($FindBin::Bin, 'data', $name);
    my $tmpdir = tempdir;

    unless (-d $base_directory) {
        die "$name is not defined";
    }

    File::Copy::Recursive::dircopy($base_directory, $tmpdir);
    $tmpdir;
}

sub prepare_as_git_repository {
    my ($directory) = @_;

    # TODO: replace with https://metacpan.org/pod/Test::Git
    system "cd $directory && git init --quiet && git config user.email 'test at example.com' &&  git config user.name 'Tester' && git add * && git commit --quiet -m 'init'";
}

1;
