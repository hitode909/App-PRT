package App::PRT::Collector::FileHandle;
use strict;
use warnings;
use File::Temp qw(tempdir tempfile);

sub new {
    my ($class, $input_fh) = @_;

    bless {
        input_fh => $input_fh,
    }, $class;
}

sub collect {
    my ($self) = @_;

    my $input_fh = $self->{input_fh};
    my $content = do { local $/; <$input_fh> };

    my $dir = tempdir( CLEANUP => 1 );

    my ($fh, $file) = tempfile('prt-XXXX', DIR => $dir, SUFFIX => '.pm');
    $self->{dir} = $dir;
    $self->{file} = $file;

    print $fh $content;
    close $fh;

    [ $file ];
}

1;
