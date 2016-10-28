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

# SEE ALSO

[prt](https://metacpan.org/pod/prt)

# LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

hitode909 <hitode909@gmail.com>
