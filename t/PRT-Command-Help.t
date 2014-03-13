package t::PRT::Command::Help;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Command::Help';
}

sub instantiate : Tests {
    isa_ok PRT::Command::Help->new, 'PRT::Command::Help';
}

sub register_rule : Tests {
    my $command = PRT::Command::Help->new;

    ok $command->help_message;
}

