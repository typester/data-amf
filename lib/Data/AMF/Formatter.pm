package Data::AMF::Formatter;
use strict;
use warnings;

use Data::AMF::Formatter::AMF0;
#use Data::AMF::Formatter::AMF3;

sub new {
    my $class = shift;
    my $args  = @_ > 1 ? {@_} : $_[0];

    $args->{version} == 3
        ? 'Data::AMF::Formatter::AMF3'
        : 'Data::AMF::Formatter::AMF0';
}

1;
