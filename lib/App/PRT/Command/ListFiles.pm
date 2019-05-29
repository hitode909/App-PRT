package App::PRT::Command::ListFiles;
# Created by CXW based on App::PRT::Command::RenameClass

use strict;
use warnings;
use Path::Class;

sub new {
    my ($class) = @_;
    bless {eol => "\n"}, $class;
}

# parse arguments from CLI.  The only argument is `-0`, to output
# filenames separated by "\0" instead of "\n".
# arguments:
#   @arguments
# returns:
#   @rest_arguments
sub parse_arguments {
    my ($self, @arguments) = @_;

    if(@arguments && $arguments[0] eq '-0') {
        shift @arguments;
        $self->{eol} = "\0";
    }

    @arguments;
}

# Output the filename.
# arguments:
#   $file: filename
sub execute {
    my ($self, $file) = @_;
    print file($file), $self->{eol};
        # Extra file() call to canonicalize
}

1;
