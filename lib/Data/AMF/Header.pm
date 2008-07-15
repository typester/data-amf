package Data::AMF::Header;
use Moose;

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has must_understand => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has length => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has value => (
    is => 'rw',
);

has version => (
    is  => 'rw',
    isa => 'Int',
);

1;


