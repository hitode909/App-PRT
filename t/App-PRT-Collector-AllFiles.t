package t::App::PRT::Collector::AllFiles;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Collector::AllFiles';
}

sub instantiate : Tests {
    my $collector = App::PRT::Collector::AllFiles->new('foo/');
    isa_ok $collector, 'App::PRT::Collector::AllFiles';
    is $collector->directory, 'foo/';
}

sub find_project_root_directory: Tests {
    subtest 'directory without cpanfile' => sub {
        my $directory = t::test::prepare_test_code('hello_world');
        is App::PRT::Collector::AllFiles->find_project_root_directory($directory), undef, 'not found';
    };

    subtest 'directory with cpanfile' => sub {
        my $directory = t::test::prepare_test_code('contain_ignores');

        is App::PRT::Collector::AllFiles->find_project_root_directory($directory), $directory, 'found from root directory';
        is App::PRT::Collector::AllFiles->find_project_root_directory("$directory/lib"), $directory, 'found from sub directory';
    };

    subtest 'not existing directory' => sub {
        ok exception {
            App::PRT::Collector::AllFiles->find_project_root_directory('/not/existing/directory');
        };
    };
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

    my $collector = App::PRT::Collector::AllFiles->new($directory);
    cmp_bag $collector->collect, $files, 'all files are returned';

    subtest 'not existing directory' => sub {
        my $collector = App::PRT::Collector::AllFiles->new('/not/existing/directory');
        ok exception {
            $collector->collect;
        };
    };
}
