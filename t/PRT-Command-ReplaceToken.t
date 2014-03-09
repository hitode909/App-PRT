package t::PRT::Command::ReplaceToken;
use t::test;
use PRT::Collector::Files;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::ReplaceToken';
}

sub instantiate : Tests {
    isa_ok PRT::Command::ReplaceToken->new, 'PRT::Command::ReplaceToken';
}

sub execute : Tests {
    my $directory = t::test::create_hello_world();
    my $command = PRT::Command::ReplaceToken->new;
    my $collector = PRT::Collector::Files->new(["$directory/hello_world.pl"]);
    $command->set_collector($collector);

    subtest 'nothing happen when source/dest specified' => sub {
        $command->execute;
        is dir($directory)->file('hello_world.pl')->slurp, file(__FILE__)->dir->file('data', 'hello_world', 'hello_world.pl')->slurp;
    };

    subtest 'tokens will be replaced when source/dest specified' => sub {
        $command->set_source_token('print');
        $command->set_dest_token('warn');
        $command->execute;
        is dir($directory)->file('hello_world.pl')->slurp, <<'CODE';
warn "Hello, World!\n";
CODE
    };

}
