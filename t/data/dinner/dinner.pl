use strict;
use warnings;
use lib 'lib';

use My::Human;
use My::Food;

undef *My::Food::new;
undef *My::Food::Foo::new;

my $human = My::Human->new('Alice');
my $food = My::Food->new('Pizza');

$human->eat($food);
