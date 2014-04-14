package t::App::PRT::Collector::AllFiles;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Collector::AllFiles';
}

sub instantiate : Tests {
    isa_ok App::PRT::Collector::AllFiles->new, 'App::PRT::Collector::AllFiles';
}

sub collect: Tests {
    my $directory = t::test::prepare_test_code('contain_ignores');

    my $files = [
        "$directory/app.psgi",
        "$directory/eg/eg.pl",
        "$directory/lib/Foo.pm",
        "$directory/lib/Foo/Bar.pm",
        "$directory/t/test.t",
    ];

    subtest 'from project root directory' => sub {
        my $g = mock_guard 'Cwd' => {
            getcwd => $directory,
        };

        my $collector = App::PRT::Collector::AllFiles->new();
        cmp_bag $collector->collect, $files, 'all files are returned';
    };

    subtest 'from sub directory' => sub {
        my $g = mock_guard 'Cwd' => {
            getcwd => "$directory/lib",
        };

        my $collector = App::PRT::Collector::AllFiles->new();
        cmp_bag $collector->collect, $files, 'all files are returned';
    };
}

sub collect_when_project_not_decided: Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $g = mock_guard 'Cwd' => {
        getcwd => $directory,
    };

    ok exception {
        App::PRT::Collector::AllFiles->new();
    }, 'project root not found';
}
