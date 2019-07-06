requires 'perl', '5.010001';
requires 'Class::Load';
requires 'Cwd';
requires 'File::Find::Rule';
requires 'File::Temp';
requires 'Getopt::Long', '2.34';        # for auto_help
requires 'IO::Interactive';
requires 'List::MoreUtils', '0.401';    # for most recent API
requires 'Path::Class';
requires 'Pod::Usage';
requires 'PPI', '0.844';    # for schild bugfix

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
    requires 'File::Basename';
    requires 'File::Copy::Recursive';
    requires 'File::pushd';
    requires 'File::Spec::Functions';
    requires 'File::Temp';
    requires 'FindBin';
    requires 'parent';
    requires 'Capture::Tiny', '0.39';
    requires 'File::pushd', '1.013';
    requires 'lib';
    requires 'List::Util', '1.43';
};

on develop => sub {
    requires 'Test::Perl::Critic';
};
