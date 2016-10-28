package t::App::PRT::Collector::FileHandle;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Collector::FileHandle';
}

sub instantiate : Tests {
    isa_ok App::PRT::Collector::FileHandle->new, 'App::PRT::Collector::FileHandle';
}

sub collect : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    my $fh = file("$directory/lib/My/Food.pm")->open;

    my $collector = App::PRT::Collector::FileHandle->new($fh);

    cmp_deeply $collector->collect, [
        re(qr/prt-....\.pm/),
    ];
}
