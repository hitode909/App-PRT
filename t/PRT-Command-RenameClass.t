package t::PRT::Command::RenameClass;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::RenameClass';
}

sub instantiate : Tests {
    isa_ok PRT::Command::RenameClass->new, 'PRT::Command::RenameClass';
}

sub register_rule : Tests {
    my $command = PRT::Command::RenameClass->new;

    $command->register('Foo' => 'Bar');

    is $command->source_class_name, 'Foo';
    is $command->destination_class_name, 'Bar';
}

sub _destination_file : Tests {
    for my $case (
        ['Foo', 'Bar', 'Foo.pm', './Bar.pm', 'without directory'],
        ['Foo', 'Bar', 'Foo.pm', './Bar.pm', 'with directory'],
        ['Foo::Bar', 'Foo::Bazz', 'Foo/Bar.pm', 'Foo/Bazz.pm', 'move deeper'],
        ['Foo::Bar::Bazz', 'Foo::Bar', 'Foo/Bar/Bazz.pm', 'Foo/Bar.pm', 'move lighter'],
        ['Foo::Bar::Bazz', 'Foo::Bar', '/tmp/lib/Foo/Bar/Bazz.pm', '/tmp/lib/Foo/Bar.pm', 'absolute path'],
        ['Test::Foo', 'Test::Foo::Bar', 't/lib/Test/Foo.pm', 't/lib/Test/Foo/Bar.pm', 't/lib'],
    ) {
        my ($source_class_name, $destination_class_name, $input_file, $expected_file, $description) = @$case;

        my $command = PRT::Command::RenameClass->new;
        $command->register($source_class_name => $destination_class_name);
        is $command->_destination_file($input_file), $expected_file, $description;
    }
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = PRT::Command::RenameClass->new;

    $command->register('My::Food' => 'My::Meal');

    subtest 'target class' => sub {
        my $food_file = "$directory/lib/My/Food.pm";
        my $meal_file = "$directory/lib/My/Meal.pm";

        $command->execute($food_file);

        ok ! -f $food_file, "Food.pm doesn't exists";
        ok -e $meal_file, "Meal.pm exists";

        is file($meal_file)->slurp, <<'CODE', 'package statement was rewritten';
package My::Meal;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

sub name {
    my ($self) = @_;

    $self->{name};
}

1;
CODE

     };

    subtest 'client file' => sub {
        my $dinner_file = "$directory/dinner.pl";
        $command->execute($dinner_file);

        ok -f $dinner_file, 'dinner.pl exists';

        is file($dinner_file)->slurp, <<'CODE', 'use statement and class-method invocation were rewritten';
use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Meal;

my $human = My::Human->new('Alice');
my $food = My::Meal->new('Pizza');

$human->eat($food);
CODE

     };
}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = PRT::Command::RenameClass->new;
        my @args = qw(From To a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        is $command->source_class_name, 'From';
        is $command->destination_class_name, 'To';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = PRT::Command::RenameClass->new;

        ok exception {
            $command->parse_arguments('hi');
        }, 'died';
    };

}
