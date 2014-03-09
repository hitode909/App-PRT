package t::test;

use strict;
use warnings;
use utf8;

use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

use File::Temp qw(tempdir);
use File::Copy::Recursive;

# use Exporter::Lite ();

our @EXPORT = qw(
    create_hello_world
);

sub import {
    my ($class) = @_;

    my ($package, $file) = caller;

    my $code = qq[
        package $package;
        use strict;
        use warnings;
        use utf8;

        use parent qw(Test::Class);
        use Test::More;
        use Test::Fatal;

        use Path::Class;

        END { $package->runtests }
    ];

    eval $code;
    die $@ if $@;
}

sub create_hello_world {
    my $tmpdir = tempdir;

    File::Copy::Recursive::dircopy(file(__FILE__)->dir->subdir('data', 'hello_world'), $tmpdir);
    $tmpdir;
}

1;
