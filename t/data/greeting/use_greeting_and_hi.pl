use strict;
use warnings;
use lib 'lib';

use Greeting;
use Hi;

print Greeting->hi('Alice');
print Greeting->bye('Bob');
