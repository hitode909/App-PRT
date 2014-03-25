package t::App::PRT::Command::Help;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::Help';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::Help->new, 'App::PRT::Command::Help';
}

sub handle_files : Tests {
    ok ! App::PRT::Command::Help->handle_files, "Help doesn't handle files";
}

sub execute : Tests {
    my $command = App::PRT::Command::Help->new;

    ok $command->execute;
}

sub parse_arguments : Tests {
    my $command = App::PRT::Command::Help->new;
    my $args = [qw(foo bar bazz)];
    cmp_deeply [$command->parse_arguments(@$args)], $args, 'NOP';
}
