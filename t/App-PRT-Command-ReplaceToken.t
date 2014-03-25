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
    my $command = App::PRT::Command::ReplaceToken->new;

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
    my $command = App::PRT::Command::ReplaceToken->new;
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
    my $command = App::PRT::Command::ReplaceToken->new;
    my $file = "$directory/hello_world.pl";

    $command->register('print' => 'die');
    $command->register('"Hello, World!\n"' => '"Bye!"');

    $command->execute($file);

        is file($file)->slurp, <<'CODE';
die "Bye!";
CODE

}

sub parse_arguments : Tests {
    subtest "when source and destination specified" => sub {
        my $command = App::PRT::Command::ReplaceToken->new;
        my @args = qw(foo bar a.pl lib/B.pm);


        my @args_after = $command->parse_arguments(@args);

        cmp_deeply $command->rules, {
            foo => 'bar',
        }, 'registered';

        cmp_deeply \@args_after, [qw(a.pl lib/B.pm)], 'parse_arguments returns rest arguments';
    };

    subtest "when arguments are not enough" => sub {
        my $command = App::PRT::Command::ReplaceToken->new;

        ok exception {
            $command->parse_arguments('hi');
        }, 'died';
    };

}
