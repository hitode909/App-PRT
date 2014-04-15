package t::App::Prt::Collector::GitDirectory;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Collector::GitDirectory';
}

sub instantiate : Tests {
    my $directory = t::test::prepare_test_code('hello_world');

    ok exception {
        App::PRT::Collector::GitDirectory->new;
    }, 'directory required';

    ok exception {
        App::PRT::Collector::GitDirectory->new('not_exist_directory');
    }, 'existing directory required';

    ok exception {
        App::PRT::Collector::GitDirectory->new($directory);
    }, 'git directory required';

    t::test::prepare_as_git_repository($directory);

    subtest 'can initialize with git repository' => sub {
        my $collector = App::PRT::Collector::GitDirectory->new($directory);
        isa_ok $collector, 'App::PRT::Collector::GitDirectory';
        is $collector->directory, $directory, 'collector has directory';
        is_deeply $collector->collect, [ "$directory/hello_world.pl" ], 'collector can collect';
    };
}

sub collect : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    t::test::prepare_as_git_repository($directory);

    my $collector = App::PRT::Collector::GitDirectory->new($directory);

    cmp_bag $collector->collect, [
        "$directory/dinner.pl",
        "$directory/lib/My/Food.pm",
        "$directory/lib/My/Human.pm",
        "$directory/t/001-my-food._t",
        "$directory/t/My-Food._t",
    ], 'all files in directory are returned';
}
