package t::App::PRT::Command::AddMethod;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Command::AddMethod';
}

sub instantiate : Tests {
    isa_ok App::PRT::Command::AddMethod->new, 'App::PRT::Command::AddMethod';
}

sub register : Tests {
    my $command = App::PRT::Command::AddMethod->new;

    $command->register('sub one { 1 }');

    is $command->code, 'sub one { 1 }';
}

sub execute : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::AddMethod->new;

    $command->register(<<SUB);
sub one {
    return 1;
}
SUB

    my $human_file = "$directory/lib/My/Human.pm";

    subtest 'target file' => sub {
        $command->execute($human_file);

        is file($human_file)->slurp, <<'CODE', 'sub one added to last';
package My::Human;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

sub name {
    my ($self) = @_;

    $self->{name};
}

sub eat {
    my ($self, $food) = @_;

    print "@{[ $self->name ]} is eating @{[ $food->name ]}.\n";
}

sub one {
    return 1;
}

1;
CODE

     };
}

sub execute_with_comment : Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $command = App::PRT::Command::AddMethod->new;

    $command->register(<<SUB);

# returns 1
# You can use when you want one
sub one {
    return 1;
}
SUB

    my $human_file = "$directory/lib/My/Human.pm";

    subtest 'target file' => sub {
        $command->execute($human_file);

        is file($human_file)->slurp, <<'CODE', 'sub one added to last';
package My::Human;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

sub name {
    my ($self) = @_;

    $self->{name};
}

sub eat {
    my ($self, $food) = @_;

    print "@{[ $self->name ]} is eating @{[ $food->name ]}.\n";
}

# returns 1
# You can use when you want one
sub one {
    return 1;
}

1;
CODE

     };
}
