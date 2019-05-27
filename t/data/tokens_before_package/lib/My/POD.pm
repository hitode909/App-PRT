=head1 NAME

My::POD - A package with POD before the `package` statement

=cut

package My::POD;
use strict;
use warnings;

sub new { bless {}, shift; }

1;
