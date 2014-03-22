requires 'PPI';
requires 'Class::Load';

on 'test' => sub {
    test_requires 'Path::Class';
    test_requires 'Test::More';
    test_requires 'Test::Class';
    test_requires 'Test::Fatal';
    test_requires 'Test::Deep';
    test_requires 'File::Temp';
    test_requires 'File::Copy::Recursive';
    test_requires 'Test::Mock::Guard';

    test_requires 'Devel::Cover::Report::Coveralls';
};
