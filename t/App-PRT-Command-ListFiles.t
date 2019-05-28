package t::App::PRT::Command::ListFiles;
use t::test;

use Capture::Tiny 'capture';
use File::pushd;

sub _require : Test(startup => 2) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::ListFiles';
    use_ok 'App::PRT::CLI';
        # ListFiles can only be meaningfully tested through the CLI,
        # since all it does is report values the CLI provides.
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::ListFiles->new, 'App::PRT::Command::ListFiles';
}

sub execute_NL : Tests {        # Output ending with \n
    my $directory = t::test::prepare_test_code('list_files');

    my ($stdout, $stderr, @result);
    do {    # Modified from script/prt
        my $guard = pushd($directory);
        my $cli = App::PRT::CLI->new;
        $cli->set_io(*STDIN, *STDOUT);
        $cli->parse(qw(list_files));
        ($stdout, $stderr, @result) = capture { $cli->run; };
    };

    ok !$stderr, 'No error output from list_files';
    like $stdout, qr/\n/, 'Output contains a newline';
    unlike $stdout, qr/\0/, 'Output contains no nulls';
    my @result_lines = sort split("\n", $stdout);
    cmp_ok @result_lines, '==', 2, 'Found the right number of files';

    my $expected = file($directory, qw(bin amazing.pl));
    like $result_lines[0], qr/\Q$expected\E$/, 'First result matches';

    $expected = file($directory, qw(lib My Class.pm));
    like $result_lines[1], qr/\Q$expected\E$/, 'Second result matches';

}

sub execute_0 : Tests {         # Output ending with \0
    my $directory = t::test::prepare_test_code('list_files');

    my ($stdout, $stderr, @result);
    do {    # Modified from script/prt
        my $guard = pushd($directory);
        my $cli = App::PRT::CLI->new;
        $cli->set_io(*STDIN, *STDOUT);
        $cli->parse(qw(list_files -0));
        ($stdout, $stderr, @result) = capture { $cli->run; };
    };

    ok !$stderr, 'No error output from list_files';
    unlike $stdout, qr/\n/, 'Output contains no newlines';
    like $stdout, qr/\0/, 'Output contains a null';
    my @result_lines = sort split("\0", $stdout);
    cmp_ok @result_lines, '==', 2, 'Found the right number of files';

    my $expected = file($directory, qw(bin amazing.pl));
    like $result_lines[0], qr/\Q$expected\E$/, 'First result matches';

    $expected = file($directory, qw(lib My Class.pm));
    like $result_lines[1], qr/\Q$expected\E$/, 'Second result matches';

}

