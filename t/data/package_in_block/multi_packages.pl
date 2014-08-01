use strict;
use warnings;

package Bye {
    sub bye { "bye" }
};

package Hello {
    sub hello { "hello" }
};

print Hello->hello;
