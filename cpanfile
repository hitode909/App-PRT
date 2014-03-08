requires 'PPI';

on 'test' => sub {
    test_requires 'Path::Class';
    test_requires 'Test::More';
    test_requires 'Test::Class';
    test_requires 'File::Temp';
    test_requires 'File::Copy::Recursive';
};
