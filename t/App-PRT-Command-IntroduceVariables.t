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
    my $directory = t::test::prepare_test_code('dinner');
    my $food_file = "$directory/lib/My/Food.pm";

    my $command = App::PRT::Command::IntroduceVariables->new;

    is_deeply $command->collect_variables($food_file), [
        '$My::Food::SOME_MAGIC_NUMBER',
        '$My::Food::Foo::GLOBAL_VAR',
        '$class',
        '$name',
        '@_',
        '$self',
    ];
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');
    my $food_file = "$directory/lib/My/Food.pm";

    my $command = App::PRT::Command::IntroduceVariables->new;
    my $out_file = file("$directory/out.txt");
    my $out_fh = $out_file->openw;

    $command->execute($food_file, $out_fh);

    close $out_fh;
    is $out_file->slurp, <<'CODE', 'variables introduces';
$My::Food::SOME_MAGIC_NUMBER
$My::Food::Foo::GLOBAL_VAR
$class
$name
@_
$self
CODE

}
