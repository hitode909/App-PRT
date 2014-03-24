package PRT;
use strict;
use warnings;

our $VERSION = "0.01";

sub welcome {
    'welcome!!!!';
}

1;
__END__

=encoding utf-8

=head1 NAME

PRT - Command line Perl Refacoring Tool

=head1 SYNOPSIS

    use PRT::CLI;
    my $cli = PRT::CLI->new;
    $cli->parse(@ARGV);
    $cli->run;


=head1 DESCRIPTION

PRT is command line tools for Refactoring Perl.

=head1 LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut

