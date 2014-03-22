package t::PRT::Command::Help;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::Help';
}

sub instantiate : Tests {
    isa_ok PRT::Command::Help->new, 'PRT::Command::Help';
}

sub execute : Tests {
    my $command = PRT::Command::Help->new;

    ok $command->execute;
}

