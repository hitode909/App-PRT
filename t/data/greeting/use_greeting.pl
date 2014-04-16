use strict;
use warnings;
use lib 'lib';

use Greeting;

print Greeting->hi('Alice');
print Greeting->bye('Bob');
