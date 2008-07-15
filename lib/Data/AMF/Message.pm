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

has version => (
    is  => 'rw',
    isa => 'Int',
);

sub result {
    my ($self, $obj) = @_;

    my $class = blessed $self;

    $class->new(
        target_uri   => $self->response_uri . '/onResult',
        response_uri => '',
        length       => -1,
        value        => $obj,
        version      => $self->version,
    );
}

sub error {
    my ($self, $obj) = @_;

    my $class = blessed $self;

    $class->new(
        target_uri   => $self->response_uri . '/onStatus',
        response_uri => '',
        length       => -1,
        value        => $obj,
        version      => $self->version,
    );
}

1;

