package t::PRT::Collector::GitDirectory;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Collector::GitDirectory';
}

sub instantiate : Tests {
    my $directory = t::test::prepare_test_code('hello_world');

    ok exception {
        PRT::Collector::GitDirectory->new;
    }, 'directory required';

    ok exception {
        PRT::Collector::GitDirectory->new('not_exist_directory');
    }, 'existing directory required';

    ok exception {
        PRT::Collector::GitDirectory->new($directory);
    }, 'git directory required';

    t::test::prepare_as_git_repository($directory);

    subtest 'can initialize with git repository' => sub {
        my $collector = PRT::Collector::GitDirectory->new($directory);
        isa_ok $collector, 'PRT::Collector::GitDirectory';
        is $collector->directory, $directory, 'collector has directory';
        is_deeply $collector->collect, [ "$directory/hello_world.pl" ], 'collector can collect';
    };
}

sub collect_multi_files : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    t::test::prepare_as_git_repository($directory);

    my $collector = PRT::Collector::GitDirectory->new($directory);

    is_deeply $collector->collect, [
        "$directory/dinner.pl",
        "$directory/lib/My/Food.pm",
        "$directory/lib/My/Human.pm",
    ];
}
