package t::TestForTest;
use t::test;

sub _prepare_test_code : Tests {
    subtest 'valid input' => sub {
        my $directory = t::test::prepare_test_code('hello_world');

        ok $directory;
        ok -d $directory, 'directory exists';

        ok -f "$directory/hello_world.pl", 'hello_world.pl exists';
    };

    subtest 'valid input' => sub {
        ok exception {
            t::test::prepare_test_code('not_defined_name');
        }, 'dies when specified code is not prepared'
    };
}
