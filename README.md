[![Build Status](https://travis-ci.org/hitode909/App-PRT.svg?branch=master)](https://travis-ci.org/hitode909/App-PRT) [![Coverage Status](https://img.shields.io/coveralls/hitode909/App-PRT/master.svg?style=flat)](https://coveralls.io/r/hitode909/App-PRT?branch=master)
# NAME

App::PRT - Command line Perl Refactoring Tool

# SYNOPSIS

    use App::PRT::CLI;
    my $cli = App::PRT::CLI->new;
    $cli->parse(@ARGV);
    $cli->run;

# DESCRIPTION

App::PRT is command line tools for Refactoring Perl.

# CONTRIBUTING

App::PRT uses [Minilla](https://metacpan.org/pod/Minilla) for development.  The tests assume `.` is in the
Perl library path.  On Perl 5.26+, before running `minil test`, add `.`
to the path.  For example, in `bash`:

    export PERL5LIB="$PERL5LIB":.

Each command in the [prt](https://metacpan.org/pod/prt) tool is implemented by a corresponding class
under `App::PRT::Command`.  For example, `rename_class` is implemented
by [App::PRT::Command::RenameClass](https://metacpan.org/pod/App::PRT::Command::RenameClass).

# SEE ALSO

[prt](https://metacpan.org/pod/prt) for command-line usage.

# LICENSE

Copyright (C) 2014-2019 hitode909 and contributors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

hitode909 <hitode909@gmail.com>
