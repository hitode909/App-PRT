package t::PRT::Command::ReplaceToken;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::ReplaceToken';
}

sub instantiate : Tests {
    isa_ok PRT::Command::ReplaceToken->new, 'PRT::Command::ReplaceToken';
}

sub register_rules : Tests {
    my $command = PRT::Command::ReplaceToken->new;

    is_deeply $command->rules, {}, 'empty';

    is $command->rule('print'), undef, 'not registered';

    $command->register('print' => 'warn');

    is $command->rule('print'), 'warn', 'registered';

    is_deeply $command->rules, {
        'print' => 'warn',
    }, 'registered';

    $command->register('print' => 'say');

    is_deeply $command->rules, {
        'print' => 'say',
    }, 'updated';

    $command->register('say' => 'print');

    is_deeply $command->rules, {
        'print' => 'say',
        'say' => 'print',
    }, 'added';
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('hello_world');
    my $command = PRT::Command::ReplaceToken->new;
    my $file = "$directory/hello_world.pl";

    subtest 'nothing happen when no rules are specified' => sub {
        $command->execute($file);
        is file($file)->slurp, <<'CODE';
print "Hello, World!\n";
CODE
    };

    subtest 'tokens will be replaced when a rules is specified' => sub {
        $command->register('print' => 'warn');
        $command->execute($file);
        is file($file)->slurp, <<'CODE';
warn "Hello, World!\n";
CODE
    };

}

sub execute_when_many_rules : Tests {
    my $directory = t::test::prepare_test_code('hello_world');
    my $command = PRT::Command::ReplaceToken->new;
    my $file = "$directory/hello_world.pl";

    $command->register('print' => 'die');
    $command->register('"Hello, World!\n"' => '"Bye!"');

    $command->execute($file);

        is file($file)->slurp, <<'CODE';
die "Bye!";
CODE

}
