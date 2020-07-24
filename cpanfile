requires 'perl', '5.010001';
requires 'Class::Load', '0.25';
requires 'Cwd';
requires 'File::Find::Rule', '0.34';
requires 'File::Temp';
requires 'Getopt::Long', '2.34';        # for auto_help
requires 'IO::Interactive', '1.022';
requires 'List::MoreUtils', '0.428';    # for most recent API
requires 'Path::Class', '0.37';
requires 'Pod::Usage';
requires 'PPI', '1.270';    # for schild bugfix

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build', '0.4231';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Class', '0.50';
    requires 'Test::Fatal', '0.014';
    requires 'Test::Deep', '1.130';
    requires 'Test::Mock::Guard', '0.10';
    requires 'Path::Class', '0.37';
    requires 'File::Basename';
    requires 'File::Copy::Recursive', '0.45';
    requires 'File::pushd', '1.016';
    requires 'File::Spec::Functions';
    requires 'File::Temp';
    requires 'FindBin';
    requires 'parent';
    requires 'Capture::Tiny', '0.48';
    requires 'File::pushd', '1.016';
    requires 'lib';
    requires 'List::Util', '1.43';
};

on develop => sub {
    requires 'Test::Perl::Critic', '1.04';
};
