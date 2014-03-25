[![Build Status](https://travis-ci.org/hitode909/App-PRT.png?branch=master)](https://travis-ci.org/hitode909/App-PRT) [![Coverage Status](https://coveralls.io/repos/hitode909/App-PRT/badge.png?branch=master)](https://coveralls.io/r/hitode909/App-PRT?branch=master)
# NAME

App::PRT - Command line Perl Refacoring Tool

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
