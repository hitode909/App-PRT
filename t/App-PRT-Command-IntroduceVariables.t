package t::App::PRT::Command::IntroduceVariables;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::IntroduceVariables';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::IntroduceVariables->new, 'App::PRT::Command::IntroduceVariables';
}

sub collect_variables : Tests {
    my $command = App::PRT::Command::IntroduceVariables->new;
    is_deeply $command->collect_variables('print $foo; print $bar;'), ['$foo', '$bar'];
}

