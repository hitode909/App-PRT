package t::App::PRT::Command::AddUse;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::AddUse';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::AddUse->new, 'App::PRT::Command::AddUse';
}

sub handle_files : Tests {
    ok App::PRT::Command::AddUse->handle_files, 'AddUse handles files';
}

sub register : Tests {
    subtest 'package' => sub {
        my $command = App::PRT::Command::AddUse->new;
        $command->register('My::Package');
        is $command->namespace, 'My::Package';
    };

    subtest 'package and arguments' => sub {
        my $command = App::PRT::Command::AddUse->new;
        $command->register('My::Package qw()');
        is $command->namespace, 'My::Package qw()';
    };
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::AddUse->new;

    $command->register('Hi');

    subtest 'script with use statement, not using Hi' => sub {
        my $file = "$directory/use_greeting.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'Hi was added';
use strict;
use warnings;
use lib 'lib';

use Greeting;
use Hi;

print Greeting->hi('Alice');
print Greeting->bye('Bob');
CODE
    };

    subtest 'script, already using Hi' => sub {
        my $file = "$directory/use_greeting_and_hi.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'Hi was not added';
use strict;
use warnings;
use lib 'lib';

use Greeting;
use Hi;

print Greeting->hi('Alice');
print Greeting->bye('Bob');
CODE
    };

    subtest 'script without any use, but with package statement' => sub {
        my $file = "$directory/no_use_but_package.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'Hi was added after package statement';
package Main;
use Hi;

print Greeting->hi('Alice');
print Greeting->bye('Bob');
CODE
    };
}

