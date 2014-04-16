package t::App::PRT::Util::DestinationFile;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Util::DestinationFile';
}

sub destination_file : Tests {
    for my $case (
        ['Foo', 'Bar', 'Foo.pm', './Bar.pm', 'without directory'],
        ['Foo', 'Bar', 'Foo.pm', './Bar.pm', 'with directory'],
        ['Foo', 'Bar', 'Foo.txt', './Bar.txt', 'with extname'],
        ['Foo::Bar', 'Foo::Bazz', 'Foo/Bar.pm', 'Foo/Bazz.pm', 'move deeper'],
        ['Foo::Bar::Bazz', 'Foo::Bar', 'Foo/Bar/Bazz.pm', 'Foo/Bar.pm', 'move lighter'],
        ['Foo::Bar::Bazz', 'Foo::Bar', '/tmp/lib/Foo/Bar/Bazz.pm', '/tmp/lib/Foo/Bar.pm', 'absolute path'],
        ['Test::Foo', 'Test::Foo::Bar', 't/lib/Test/Foo.pm', 't/lib/Test/Foo/Bar.pm', 't/lib'],
        ['t::Foo', 't::Bar', 't/Foo.t', 't/Bar.t', 'test file'],
        ['A::B::C', 'D::E::F', 'A-B_C.pm', './D-E_F.pm', 'separated with -, _'],
        ['A::B', 'A::B::C::D', 'A-B.pm', './A-B-C-D.pm', 'separated with -, _, move deeper'],
        ['A::B::C::D', 'A::B', 'A-B-C-D.pm', './A-B.pm', 'separated with -, _, move lighter'],
        ['A::B::C', 'D::E::F::G', 'A/B-C.pm', 'D/E-F-G.pm', 'separated with -, _, mixed with directory'],
    ) {
        my ($source_class_name, $destination_class_name, $input_file, $expected_file, $description) = @$case;

        is App::PRT::Util::DestinationFile::destination_file($source_class_name => $destination_class_name => $input_file), $expected_file, $description;
    }
}

