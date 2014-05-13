package t::App::PRT::Command::ReplaceToken;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::ReplaceToken';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::ReplaceToken->new, 'App::PRT::Command::ReplaceToken';
}

sub handle_files : Tests {
    ok App::PRT::Command::ReplaceToken->handle_files, 'ReplaceToken handles files';
}

sub register_rules : Tests {
    subtest 'single token' => sub {
        my $command = App::PRT::Command::ReplaceToken->new;

        is $command->source_tokens, undef;
        is $command->destination_tokens, undef;

        $command->register('print' => 'warn');

        is_deeply $command->source_tokens, [ 'print' ];
        is_deeply $command->destination_tokens, [ 'warn' ];
    };

    subtest 'multi tokens' => sub {
        my $command = App::PRT::Command::ReplaceToken->new;

        is $command->source_tokens, undef;
        is $command->destination_tokens, undef;

        $command->register('$foo->bar' => '$bar->baz->qux');

        is_deeply $command->source_tokens, [ '$foo', '->', 'bar' ];
        is_deeply $command->destination_tokens, [ '$bar', '->', 'baz', '->', 'qux' ];
    };

    subtest 'replace_only_statement_which_has_token' => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        is $command->replace_only_statement_which_has_token, undef;
        $command->set_replace_only_statement_which_has_token('$fh');
        is $command->replace_only_statement_which_has_token, '$fh';
    };
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('hello_world');
    my $command = App::PRT::Command::ReplaceToken->new;
    my $file = "$directory/hello_world.pl";

    subtest 'nothing happen when no rules are specified' => sub {
        ok ! $command->execute($file), 'fails';
        is file($file)->slurp, <<'CODE', 'nothing changed';
print "Hello, World!\n";
CODE
    };

    subtest 'tokens will be replaced when a rules is specified' => sub {
        $command->register('print' => 'warn');
        ok $command->execute($file), 'success';
        is file($file)->slurp, <<'CODE', 'changed';
warn "Hello, World!\n";
CODE
    };
}

sub execute_with_replace_only_statement_which_has_token : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    subtest 'only statement with My::Food was replaced' => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        $command->register(new => 'new->bake');
        $command->set_replace_only_statement_which_has_token('My::Food');

        my $file = "$directory/dinner.pl";
        $command->execute($file);
        is file($file)->slurp, <<'CODE';
use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Food;

undef *My::Food::new;
undef *My::Food::Foo::new;

my $human = My::Human->new('Alice');
my $food = My::Food->new->bake('Pizza');

$human->eat($food);
CODE
    };

    subtest 'only statement with My::Food was replaced' => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        $command->register('$class' => '$klass');
        $command->set_replace_only_statement_which_has_token('@_');

        my $file = "$directory/lib/My/Food.pm";
        $command->execute($file);
        is file($file)->slurp, <<'CODE', 'target is `my ($class, $name) = @_;`, not subroutine';
package My::Food;
use strict;
use warnings;
$My::Food::SOME_MAGIC_NUMBER = '0.01';
$My::Food::Foo::GLOBAL_VAR = 'foobar';

sub new {
    my ($klass, $name) = @_;

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
}

sub execute_replace_token_sequences : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register('My::Human->new' => 'NewHuman');

    my $file = "$directory/dinner.pl";
    $command->execute($file);
    is file($file)->slurp, <<'CODE';
use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Food;

undef *My::Food::new;
undef *My::Food::Foo::new;

my $human = NewHuman('Alice');
my $food = My::Food->new('Pizza');

$human->eat($food);
CODE
}

sub execute_replace_token_sequences_in_statement : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register('new(' => 'new->bake('); # `new` and `(`
    $command->set_replace_only_statement_which_has_token('My::Food');

    my $file = "$directory/dinner.pl";
    $command->execute($file);
    is file($file)->slurp, <<'CODE', 'new( in statement with My::Food was replaced';
use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Food;

undef *My::Food::new;
undef *My::Food::Foo::new;

my $human = My::Human->new('Alice');
my $food = My::Food->new->bake('Pizza');

$human->eat($food);
CODE
}

sub execute_with_whitespace : Tests {
    my $directory = t::test::prepare_test_code('method_call_with_whitespace');
    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register("hello('World')"  => "hello('Work')");

    my $file = "$directory/hello.pl";
    $command->execute($file);
    is file($file)->slurp, <<'CODE', 'all hello are replaced';
hello('Work');
hello('Work');
hello('Work');
CODE
}

sub execute_for_not_perl_file: Tests {
    my $directory = t::test::prepare_test_code('readme');
    my $readme = "$directory/README.md";

    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register('alice' => 'bob');
    $command->execute($readme);
    ok -f $readme, 'README exists';
}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        my @args = qw(foo bar a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        cmp_deeply $command, methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
            replace_only_statement_which_has_token => undef,
        ), 'registered';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when source, destination, and --in-statement specified" => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        my @args = qw(foo bar --in-statement bazz a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        cmp_deeply $command, methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
            replace_only_statement_which_has_token => 'bazz',
        ), 'registered';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::ReplaceToken->new;

        ok exception {
            $command->parse_arguments('hi');
        }, 'died';
    };

}
