package t::TestForTest;
use t::test;

sub _create_hello_world : Tests {
    my $directory = t::test::create_hello_world();

    ok $directory;
    ok -d $directory, 'directory exists';

    ok -f "$directory/hello_world.pl", 'hello_world.pl exists';
}
