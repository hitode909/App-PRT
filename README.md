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

# Usage

Replace `foo` token with `bar`.

    prt replace_tokens foo bar lib/**/**.pm

Rename `Foo` class to `Bar` class.

    prt rename_class   Foo Bar lib/**/**.pm

Delete `eat` method from `Food` class.

    prt delete_method Food eat lib/**/**.pm

# LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

hitode909 <hitode909@gmail.com>
