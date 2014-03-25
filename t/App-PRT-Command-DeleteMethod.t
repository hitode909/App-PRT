package t::App::PRT::Command::DeleteMethod;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::DeleteMethod';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::DeleteMethod->new, 'App::PRT::Command::DeleteMethod';
}

sub handle_files : Tests {
    ok App::PRT::Command::DeleteMethod->handle_files, 'DeleteMethod handles files';
}

sub register : Tests {
    my $command = App::PRT::Command::DeleteMethod->new;

    $command->register('My::Food' => 'name');

    is $command->target_class_name, 'My::Food';
    is $command->target_method_name, 'name';
}

sub parse_arguments : Tests {
    subtest "when class and method specified" => sub {
        my $command = App::PRT::Command::DeleteMethod->new;
        my @args = qw(Class method a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        is $command->target_class_name, 'Class';
        is $command->target_method_name, 'method';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::DeleteMethod->new;

        ok exception {
            $command->parse_arguments('Method');
        }, 'died';
    };

}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::DeleteMethod->new;

    $command->register('My::Human' => 'name');

    my $human_file = "$directory/lib/My/Human.pm";
    my $food_file  = "$directory/lib/My/Food.pm";

    subtest 'target file' => sub {
        $command->execute($human_file);

        is file($human_file)->slurp, <<'CODE', 'name removed';
package My::Human;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}



sub eat {
    my ($self, $food) = @_;

    print "@{[ $self->name ]} is eating @{[ $food->name ]}.\n";
}

1;
CODE

     };


    subtest 'another file' => sub {
        my $before = file($food_file)->slurp;
        $command->execute($food_file);
        is file($food_file)->slurp, $before, 'nothing happen';
    };

}

