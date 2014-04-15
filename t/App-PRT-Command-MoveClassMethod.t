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

sub execute : Tests {
    my $directory = t::test::prepare_test_code('greeting');

    my $command = App::PRT::Command::MoveClassMethod->new;

    $command->register('Greeting#hi' => 'Hi#hello');

    subtest 'client' => sub {
        my $file = "$directory/greeting.pl";
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
