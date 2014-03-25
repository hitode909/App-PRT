requires 'perl', '5.010001';
requires 'Class::Load';
requires 'Getopt::Long', '2.42';
requires 'PPI';
requires 'Path::Class';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Class';
    requires 'Test::Fatal';
    requires 'Test::Deep';
    requires 'Test::Mock::Guard';
    requires 'Path::Class';
    requires 'File::Temp';
    requires 'File::Copy::Recursive';
    requires 'parent';
};

on develop => sub {
    requires 'Test::Perl::Critic';
};
