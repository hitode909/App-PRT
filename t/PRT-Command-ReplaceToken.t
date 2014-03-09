package t::PRT::Command::ReplaceToken;
use t::test;

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
    my $file = "$directory/hello_world.pl";

    subtest 'nothing happen when source/dest specified' => sub {
        $command->execute($file);
        is file($file)->slurp, file(__FILE__)->dir->file('data', 'hello_world', 'hello_world.pl')->slurp;
    };

    subtest 'tokens will be replaced when source/dest specified' => sub {
        $command->set_source_token('print');
        $command->set_dest_token('warn');
        $command->execute($file);
        is file($file)->slurp, <<'CODE';
warn "Hello, World!\n";
CODE
    };

}
