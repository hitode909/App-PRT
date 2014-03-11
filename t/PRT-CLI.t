package t::PRT::CLI;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::CLI';
}

sub instantiate : Tests {
    isa_ok PRT::CLI->new, 'PRT::CLI';
}

sub run : Tests {
    my $cli = PRT::CLI->new;

    ok ! exception {
        $cli->run('help');
    }, 'can run';

}
