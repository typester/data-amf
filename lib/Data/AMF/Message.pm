package Data::AMF::Message;
use Moose;

has target_uri => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has response_uri => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has length => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has value => (
    is => 'rw',
);

1;

