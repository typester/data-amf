package Data::AMF::Object;
use Moose;

use constant PARSER => [
    \&parse_number,
    \&parse_boolean,
    \&parse_string,
    \&parse_object,
    \&parse_movieclip,
    \&parse_null,
    \&parse_undefined,
    \&parse_reference,
    \&parse_ecma_array,
    sub { },                    # object end
    \&parse_strict_array,
    \&parse_date,
    \&parse_long_string,
    \&parse_
];

sub parse {
    
}

1;


