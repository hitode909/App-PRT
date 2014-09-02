package App::PRT;
use strict;
use warnings;
use 5.010001;

our $VERSION = "0.19";

sub welcome {
    'welcome!!!!';
}

1;
__END__

=encoding utf-8

=head1 NAME

App::PRT - Command line Perl Refactoring Tool

=head1 SYNOPSIS

    use App::PRT::CLI;
    my $cli = App::PRT::CLI->new;
    $cli->parse(@ARGV);
    $cli->run;

=head1 DESCRIPTION

App::PRT is command line tools for Refactoring Perl.

=head1 SEE ALSO

L<prt>

=head1 LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut
