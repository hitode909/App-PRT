package t::App::PRT::Command::MoveClassMethod;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::MoveClassMethod';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::MoveClassMethod->new, 'App::PRT::Command::MoveClassMethod';
}

sub handle_files : Tests {
    ok App::PRT::Command::MoveClassMethod->handle_files, 'MoveClassMethod handles files';
}

sub register_rule : Tests {

    subtest 'valid rule' => sub {
        my $command = App::PRT::Command::MoveClassMethod->new;
        $command->register('Source#source' => 'Dest#dest');

        is $command->source_class_name, 'Source';
        is $command->source_method_name, 'source';
        is $command->destination_class_name, 'Dest';
        is $command->destination_method_name, 'dest';
    };

    subtest 'invalid syntax' => sub {
        my $command = App::PRT::Command::MoveClassMethod->new;
        ok exception {
            $command->register('Source#source' => 'Dest');
        }, qr/invalid format/;
        ok exception {
            $command->register('Source#sou#rce' => 'Dest');
        }, qr/invalid format/;
        ok exception {
            $command->register('Source' => 'Dest#dest');
        }, qr/invalid format/;
    };
}

sub execute_method_body_when_destination_file_exists : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('Greeting#hi' => 'Hi#hello');

    my $file = "$directory/lib/Greeting.pm";
    $command->execute($file);

    ok -f $file, 'File exists';
    is file($file)->slurp, <<'CODE', 'hi method was removed';
package Greeting;
use strict;
use warnings;
use Hello;
use GoodAfternoon;

sub bye {
    my ($class, $name) = @_;

    "Bye, $name\n";
}

1;
CODE
    my $source_method = <<'METHOD';
sub hi {
    my ($class, $name) = @_;

    "Hi, $name\n";
}

METHOD

    is $command->source_method_body, $source_method, 'method body stored';

    my $destination_method = <<'METHOD';
sub hello {
    my ($class, $name) = @_;

    "Hi, $name\n";
}

METHOD

    is $command->destination_method_body, $destination_method, 'destination method prepared';

    my $destination_file = "$directory/lib/Hi.pm";
    ok -f $destination_file, 'destination file exists';

    is file($destination_file)->slurp, <<'CODE', 'hello method was added, use GoodAfternoon was added because it may be necessary';
package Hi;
use strict;
use warnings;
use Hello;
use GoodAfternoon;

sub good_morning {
    my ($class, $name) = @_;

    "Good morning, $name\n";
}

sub hello {
    my ($class, $name) = @_;

    "Hi, $name\n";
}

1;
CODE

}

sub execute_method_body_when_destination_file_not_exists : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('Greeting#hi' => 'Salutation#hello');

    my $file = "$directory/lib/Greeting.pm";
    $command->execute($file);
    ok -f $file, 'source file exists';

    my $destination_file = "$directory/lib/Salutation.pm";
    ok -f $destination_file, 'destination file exists';

        is file($destination_file)->slurp, <<'CODE', 'hello was added, uses are copied';
package Salutation;
use strict;
use warnings;
use Hello;
use GoodAfternoon;

sub hello {
    my ($class, $name) = @_;

    "Hi, $name\n";
}

1;
CODE
}

sub execute_method_move_comment_too : Tests {
    my $directory = t::test::prepare_test_code('method_with_comment');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('FoodWithComment#new' => 'AnotherClass#another_new');

    my $file = "$directory/FoodWithComment.pm";
    $command->execute($file);

    my $destination_file = "$directory/AnotherClass.pm";
    ok -f $destination_file, 'destination file exists';

    is file($destination_file)->slurp, <<'CODE', 'method and comment was added';
package AnotherClass;
use strict;
use warnings;

# create a new food
# You can use when you want to create a new instance
sub another_new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

1;
CODE
}

sub execute_call_as_class_method : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('Bye#good' => 'Good#very_good');

    my $file = "$directory/lib/Bye.pm";
    $command->execute($file);
    ok -f $file, 'source file exists';

    is file($file)->slurp, <<'CODE', 'use was Added, $class->good was replaced';
package Bye;
use strict;
use warnings;
use Hello;
use Good;

sub good_bye {
    my ($class, $name) = @_;

    Good->very_good("bye, $name\n");
}

1;
CODE
}

sub execute_client_script : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('Greeting#hi' => 'Hi#hello');

    subtest 'client script with use Greeting' => sub {
        my $file = "$directory/use_greeting.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'calling Greeting#hi was rewritten, use Hi was added';
use strict;
use warnings;
use lib 'lib';

use Greeting;
use Hi;

print Hi->hello('Alice');
print Greeting->bye('Bob');
CODE
    };

    subtest 'client script with use Greeting and Hi' => sub {
        my $file = "$directory/use_greeting_and_hi.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'calling Greeting#hi was rewritten, Hi was not added';
use strict;
use warnings;
use lib 'lib';

use Greeting;
use Hi;

print Hi->hello('Alice');
print Greeting->bye('Bob');
CODE
    };

    subtest 'client script without Greeting or Hi' => sub {
        my $file = "$directory/no_use.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'calling Greeting#hi was rewritten, Hi was added after last use';
use strict;
use warnings;
use lib 'lib';
use Hi;

print Hi->hello('Alice');
print Greeting->bye('Bob');
CODE
    };

    subtest 'client script without Greeting or Hi, with package statement' => sub {
        my $file = "$directory/no_use_but_package.pl";
        $command->execute($file);

        ok -f $file, 'File exists';
        is file($file)->slurp, <<'CODE', 'calling Greeting#hi was rewritten, Hi was added after package statement';
package Main;
use Hi;

print Hi->hello('Alice');
print Greeting->bye('Bob');
CODE
    };
}

sub execute_for_not_perl_file: Tests {
    my $directory = t::test::prepare_test_code('readme');
    my $readme = "$directory/README.md";

    my $command = App::PRT::Command::MoveClassMethod->new;
    $command->register('Greeting#hi' => 'Hi#hello');
    $command->execute($readme);
    ok -f $readme, 'README exists';
}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = App::PRT::Command::MoveClassMethod->new;
        my @args = ('From#from', 'To#to', qw(a.pl lib/B.pm));


        my @args_after = $command->parse_arguments(@args);

        is $command->source_class_name, 'From';
        is $command->source_method_name, 'from';
        is $command->destination_class_name, 'To';
        is $command->destination_method_name, 'to';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::MoveClassMethod->new;

        ok exception {
            $command->parse_arguments('From');
        }, 'died';
    };

}
