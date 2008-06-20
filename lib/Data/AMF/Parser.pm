package Data::AMF::Parser;
use strict;
use warnings;

use Data::AMF::Parser::AMF0;
#use Data::AMF::Parser::AMF3;

sub new {
    my $class = shift;
    my $args  = @_ > 1 ? {@_} : $_[0];

    $args->{version} == 3
      ? 'Data::AMF::Parser::AMF3'
      : 'Data::AMF::Parser::AMF0';
}

1;
