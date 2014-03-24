package t::PRT::Command::DeleteMethod;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::DeleteMethod';
}

sub instantiate : Tests {
    isa_ok PRT::Command::DeleteMethod->new, 'PRT::Command::DeleteMethod';
}

sub handle_files : Tests {
    ok PRT::Command::DeleteMethod->handle_files, 'DeleteMethod handles files';
}

sub register : Tests {
    my $command = PRT::Command::DeleteMethod->new;

    $command->register('My::Food' => 'name');

    is $command->target_class_name, 'My::Food';
    is $command->target_method_name, 'name';
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = PRT::Command::DeleteMethod->new;

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

