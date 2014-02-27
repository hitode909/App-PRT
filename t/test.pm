package t::test;

use strict;
use warnings;
use utf8;

use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

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

        END { $package->runtests }
    ];

    eval $code;
    die $@ if $@;
}

1;
