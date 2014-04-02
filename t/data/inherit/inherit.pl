package Child1 {
    use DateTime;
    use utf8;
    use parent 'Parent';
};

package Child2 {
    use parent qw(Parent AnotherParent YetAnother::Parent);
};

package Child3 {
    use base 'Parent';
};

package Child4 {
    use base "Parent";
};

package Child5 {
    use base q{Parent};
};

package Child6 {
    use base qq/Parent/;
};

package GrandChild {
    use base 'Child';
};
