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
    my $command = PRT::Command::ReplaceToken->new;
    ok $command->execute;
}
