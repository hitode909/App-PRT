requires 'perl', '5.010001';
requires 'Class::Load';
requires 'Getopt::Long', '2.42';
requires 'PPI', '0.844';    # for schild bugfix
requires 'Path::Class';
requires 'File::Find::Rule';
requires 'File::Temp';
requires 'IO::Interactive';

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
    requires 'File::Copy::Recursive';
    requires 'parent';
};

on develop => sub {
    requires 'Test::Perl::Critic';
};
