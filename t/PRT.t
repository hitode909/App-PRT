package t::PRT;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT';
}

sub welcome : Tests {
    is PRT->welcome, 'welcome!!!!';
}
