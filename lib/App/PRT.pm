package App::PRT;
use strict;
use warnings;
use 5.010001;

our $VERSION = "0.22";

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

=head1 CONTRIBUTING

App::PRT uses L<Minilla> for development.  The tests assume C<.> is in the
Perl library path.  On Perl 5.26+, before running C<minil test>, add C<.>
to the path.  For example, in C<bash>:

    export PERL5LIB="$PERL5LIB":.

Each command in the L<prt> tool is implemented by a corresponding class
under C<App::PRT::Command>.  For example, C<rename_class> is implemented
by L<App::PRT::Command::RenameClass>.

=head1 SEE ALSO

L<prt> for command-line usage.

=head1 LICENSE

Copyright (C) 2014-2019 hitode909 and contributors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut
