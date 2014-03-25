package t::App::PRT;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT';
}

sub welcome : Tests {
    is App::PRT->welcome, 'welcome!!!!';
}
