package Data::AMF::IO;
use Moose;

use constant ENDIAN => unpack('S', pack('C2', 0, 1)) == 1 ? 'BIG' : 'LITTLE';

has data => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { '' },
    lazy    => 1,
);

has pos => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 0 },
    lazy    => 1,
);

__PACKAGE__->meta->make_immutable;

sub read {
    my ($self, $len) = @_;

    my $data = substr $self->data, $self->pos, $len;
    $self->pos( $self->pos + $len );

    $data;
}

sub read_u8 {
    my $self = shift;

    my $data = $self->read(1);
    unpack('C', $data);
}

sub read_u16 {
    my $self = shift;

    my $data = $self->read(2);
    unpack('n', $data);
}

sub read_s16 {
    my $self = shift;

    my $data = $self->read(2);
    unpack('s>', $data);
}

sub read_u32 {
    my $self = shift;

    my $data = $self->read(4);
    unpack('N', $data);
}

sub read_double {
    my $self = shift;

    my $data = $self->read(8);
    unpack('d>', $data);
}

sub read_utf8 {
    my $self = shift;

    my $len = $self->read_u16;
    $self->read($len);
}

sub read_utf8_long {
    my $self = shift;

    my $len = $self->read_u32;
    $self->read($len);
}

1;

