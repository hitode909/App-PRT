package App::PRT;
use strict;
use warnings;

our $VERSION = "0.03";

sub welcome {
    'welcome!!!!';
}

1;
__END__

=encoding utf-8

=head1 NAME

App::PRT - Command line Perl Refacoring Tool

=head1 SYNOPSIS

    use App::PRT::CLI;
    my $cli = App::PRT::CLI->new;
    $cli->parse(@ARGV);
    $cli->run;


=head1 DESCRIPTION

App::PRT is command line tools for Refactoring Perl.

=head1 Usage

Replace C<foo> token with C<bar>.

    prt replace_tokens foo bar lib/**/**.pm


Rename C<Foo> class to C<Bar> class.

    prt rename_class   Foo Bar lib/**/**.pm


Delete C<eat> method from C<Food> class.

    prt delete_method Food eat lib/**/**.pm


=head1 LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut
