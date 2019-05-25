package t::App::PRT::Command::RenameClass;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::RenameClass';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::RenameClass->new, 'App::PRT::Command::RenameClass';
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

        is $command->execute($food_file), $meal_file, 'returns destination file when success';

        ok ! -f $food_file, "Food.pm doesn't exist";
        ok -e $meal_file, "Meal.pm exists";

        is file($meal_file)->slurp, <<'CODE', 'package statement was rewritten';
package My::Meal;
use strict;
use warnings;
$My::Meal::SOME_MAGIC_NUMBER = '0.01';
$My::Food::Foo::GLOBAL_VAR = 'foobar';

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

        is $command->execute($dinner_file), $dinner_file, 'returns source file when success and not moved';

        ok -f $dinner_file, 'dinner.pl exists';

        is file($dinner_file)->slurp, <<'CODE', 'use statement and class-method invocation were rewritten';
use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Meal;

undef *My::Meal::new;
undef *My::Food::Foo::new;

my $human = My::Human->new('Alice');
my $food = My::Meal->new('Pizza');

$human->eat($food);
CODE

     };
}

sub execute_package_with_comment_first : Tests {
    my $directory = t::test::prepare_test_code('tokens_before_package');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('My::Commented' => 'My::Commented2');

    my $file_in = "$directory/lib/My/Commented.pm";
    my $file_out = "$directory/lib/My/Commented2.pm";

    is $command->execute($file_in), $file_out, 'returns destination file when success';

    ok ! -f $file_in, "$file_in doesn't exist";
    ok -e $file_out, "$file_out exists";

    is file($file_out)->slurp, <<'CODE', 'package statement was rewritten';
# A package with a comment before the `package` statement
package My::Commented2;
use strict;
use warnings;

sub new { bless {}, shift; }

1;
CODE

}

sub execute_package_with_pod_first : Tests {
    my $directory = t::test::prepare_test_code('tokens_before_package');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('My::POD' => 'My::POD2');

    my $file_in = "$directory/lib/My/POD.pm";
    my $file_out = "$directory/lib/My/POD2.pm";

    is $command->execute($file_in), $file_out, 'returns destination file when success';

    ok ! -f $file_in, "$file_in doesn't exist";
    ok -e $file_out, "$file_out exists";

    is file($file_out)->slurp, <<'CODE', 'package statement was rewritten';
=head1 NAME

My::POD - A package with POD before the `package` statement

=cut

package My::POD2;
use strict;
use warnings;

sub new { bless {}, shift; }

1;
CODE

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

    ok ! -f $food_file, "Food._t doesn't exist";
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

sub execute_rename_to_deeper_directory : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('My::Food' => 'My::Special::Great::Food');

    subtest 'target class' => sub {
        my $food_file = "$directory/lib/My/Food.pm";
        my $special_food_file = "$directory/lib/My/Special/Great/Food.pm";

        is $command->execute($food_file), $special_food_file, 'success';

        ok ! -f $food_file, "Food.pm doesn't exist";
        ok -e $special_food_file, "Special::Great::Food.pm exists";
    };
}

sub execute_rename_package_in_block_statement : Tests {
    my $directory = t::test::prepare_test_code('package_in_block');

    my $command = App::PRT::Command::RenameClass->new;

    $command->register('Hello' => 'Greeting');

    subtest '{ package } style' => sub {
        my $script = "$directory/package_in_block.pl";

        is $command->execute($script), $script, 'success';

        ok -e $script, "script exists";

        is file($script)->slurp, <<'CODE', 'package statement replaced';
use strict;
use warnings;

{
    package Greeting;

    sub hello { "hello!" }
};

print Greeting->hello;
CODE

    };

    subtest 'package { } style' => sub {
        my $script = "$directory/package_block_statement.pl";

        is $command->execute($script), $script, 'success';

        ok -e $script, "script exists";

        is file($script)->slurp, <<'CODE', 'package statement replaced';
use strict;
use warnings;

package Greeting {
    sub hello { "hello" }
};

print Greeting->hello;
CODE

    };

    subtest 'multi packages' => sub {
        my $script = "$directory/multi_packages.pl";

        is $command->execute($script), $script, 'success';

        ok -e $script, "script exists";

        is file($script)->slurp, <<'CODE', 'package statement replaced';
use strict;
use warnings;

package Bye {
    sub bye { "bye" }
};

package Greeting {
    sub hello { "hello" }
};

print Greeting->hello;
CODE

    };
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
