package t::App::PRT::Command::RenameClass;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::RenameClass';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::RenameClass->new, 'App::PRT::Command::RenameClass';
}

sub handle_files : Tests {
    ok App::PRT::Command::RenameClass->handle_files, 'RenameClass handles files';
}

sub register_rule : Tests {
    my $command = App::PRT::Command::RenameClass->new;

    $command->register('Foo' => 'Bar');

    is $command->source_class_name, 'Foo';
    is $command->destination_class_name, 'Bar';
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::RenameClass->new;

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

sub execute_with_inherit : Tests {
    my $directory = t::test::prepare_test_code('inherit');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('Parent' => 'Boss');

    subtest 'target class' => sub {
        my $file = "$directory/inherit.pl";

        $command->execute($file);

        ok -e $file, "script file exists";
        is file($file)->slurp, <<'CODE', 'use parent, use base statements were rewritten';
package Child1 {
    use DateTime;
    use utf8;
    use parent 'Boss';
};

package Child2 {
    use parent qw(Boss AnotherParent YetAnother::Parent);
};

package Child3 {
    use base 'Boss';
};

package Child4 {
    use base 'Boss';
};

package Child5 {
    use base 'Boss';
};

package Child6 {
    use base 'Boss';
};

package GrandChild {
    use base 'Child';
};
CODE

     };

}

sub execute_test_more_style_test_file : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('My::Food' => 'My::Meal');

    my $file = "$directory/t/001-my-food._t";

    $command->execute($file);

    is file($file)->slurp, <<'CODE', 'test replaced';
use Test::More tests => 5;

use_ok 'My::Meal';
require_ok 'My::Meal';

new_ok 'My::Meal';
isa_ok My::Meal->new, 'My::Meal';

subtest 'name' => sub {
    my $pizza = My::Meal->new('Pizza');
    is $pizza->name, 'Pizza';
};
CODE

}

sub execute_test_class_style_test_file: Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $food_file = "$directory/t/My-Food._t";
    my $meal_file = "$directory/t/My-Meal._t";

    my $command1 = App::PRT::Command::RenameClass->new;
    $command1->register('t::My::Food' => 't::My::Meal');
    $command1->execute($food_file);

    ok ! -f $food_file, "Food._t doesn't exists";
    ok -e $meal_file, "Meal._t exists";

    is file($meal_file)->slurp, <<'CODE', 'package statement replaced';
package t::My::Meal;
use base qw(Test::Class);
use Test::More;

sub _load : Test(startup => 1) {
    use_ok 'My::Food';
}

sub instantiate : Test(1) {
    isa_ok My::Food->new('banana'), 'My::Food';
}

sub name : Test(1) {
    my $food = My::Food->new('banana');
    is $food->name, 'banana';
}

__PACKAGE__->runtests;
CODE

}

sub execute_for_not_perl_file: Tests {
    my $directory = t::test::prepare_test_code('readme');
    my $readme = "$directory/README.md";

    my $command = App::PRT::Command::RenameClass->new;
    $command->register('Alice' => 'Bob');
    $command->execute($readme);
    ok -f $readme, 'README exists';
}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = App::PRT::Command::RenameClass->new;
        my @args = qw(From To a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        is $command->source_class_name, 'From';
        is $command->destination_class_name, 'To';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::RenameClass->new;

        ok exception {
            $command->parse_arguments('hi');
        }, 'died';
    };

}
