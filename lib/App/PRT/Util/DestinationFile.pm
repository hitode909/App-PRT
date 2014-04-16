package App::PRT::Util::DestinationFile;
use strict;
use warnings;
use Path::Class;


sub destination_file {
    my ($source_class_name, $destination_class_name, $input_file) = @_;

    my @delimiters = do {
        my $pattern = $source_class_name;
        $pattern =~ s{::}{(.+)}g;
        ($input_file =~ qr/^(.*)$pattern(.*)$/);
    };
    my $prefix = shift @delimiters;
    my $suffix = pop @delimiters;

    my $fallback_delimiter = $delimiters[-1];
    my $dir = file($input_file)->dir;
    $dir = $dir->parent for grep { $_ eq '/' } @delimiters;
    my $basename = $destination_class_name;
    $basename =~ s{::}{
        shift @delimiters // $fallback_delimiter;
    }ge;
    $dir->file("$basename$suffix")->stringify;
}

1;
