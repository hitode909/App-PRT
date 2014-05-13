package t::App::PRT::Command::RenameNameSpace;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::RenameNameSpace';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::RenameNameSpace->new, 'App::PRT::Command::RenameNameSpace';
}

sub handle_files : Tests {
    ok App::PRT::Command::RenameNameSpace->handle_files, 'RenameNameSpace handles files';
}

sub register_rule : Tests {
    my $command = App::PRT::Command::RenameNameSpace->new;

    $command->register('Foo' => 'Bar');

    is $command->source_name_space, 'Foo';
    is $command->destination_name_space, 'Bar';
}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = App::PRT::Command::RenameNameSpace->new;
        my @args = qw(From To a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        is $command->source_name_space, 'From';
        is $command->destination_name_space, 'To';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::RenameClass->new;

        ok exception {
            $command->parse_arguments('NotEnough');
        }, 'died';
    };

}

sub _collect_target_classes : Tests {
    my $command = App::PRT::Command::RenameNameSpace->new;
    $command->register('My' => 'Our');

    my $directory = t::test::prepare_test_code('dinner');
    cmp_bag $command->_collect_target_classes([
        "$directory/lib/My/Food.pm",
        "$directory/lib/My/Human.pm",
        "$directory/lib/Your/Food.pm",
        "$directory/dinner.pl",
    ]), [
        'My::Food',
        'My::Human',
    ], 'classes under My:: are collected';
}

sub _destination_class_name : Tests {
    my $command = App::PRT::Command::RenameNameSpace->new;
    $command->register('My' => 'Our');

    is $command->_destination_class_name('My::Food'), 'Our::Food', 'converted';
    is $command->_destination_class_name('The::My::Food'), undef, 'not match';
    is $command->_destination_class_name('Our::Food'), undef, 'not match';
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::RenameNameSpace->new;
    $command->register('My' => 'Our');

    $command->execute_files([
        "$directory/dinner.pl",
        "$directory/lib/My/Food.pm",
        "$directory/lib/My/Human.pm",
        "$directory/lib/Your/Food.pm",
        "$directory/t/001-my-food._t",
        "$directory/t/My-Food._t",
    ]);

    ok -f "$directory/dinner.pl", "script exists";

    is file("$directory/dinner.pl")->slurp, <<'CODE', 'My:: was moved to Our::';
use strict;
use warnings;
use lib 'lib';

use Our::Human;
use Our::Food;

undef *Our::Food::new;
undef *My::Food::Foo::new;

my $human = Our::Human->new('Alice');
my $food = Our::Food->new('Pizza');

$human->eat($food);
CODE

    ok ! -f "$directory/lib/My/Food.pm", "My::Food doesn't exist";
    ok ! -f "$directory/lib/My/Human.pm", "My::Human doesn't exist";
    ok -f "$directory/lib/Our/Food.pm", "Our::Food exist";
    ok -f "$directory/lib/Our/Human.pm", "Our::Human exist";

    is file("$directory/lib/Our/Food.pm")->slurp, <<'CODE', 'target class replaced';
package Our::Food;
use strict;
use warnings;
$Our::Food::SOME_MAGIC_NUMBER = '0.01';
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

    is file("$directory/lib/Your/Food.pm")->slurp, <<'CODE', 'not changed';
package Your::Food;

1;
CODE
}
