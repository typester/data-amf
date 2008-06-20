package Data::AMF::Packet;
use Moose;

use Data::AMF::Parser;
use Data::AMF::IO;

use Data::AMF::Header;
use Data::AMF::Message;

has version => (
    is  => 'rw',
    isa => 'Int',
);

has headers => (
    is  => 'rw',
    isa => 'ArrayRef',
);

has messages => (
    is  => 'rw',
    isa => 'ArrayRef',
);

__PACKAGE__->meta->make_immutable;

sub deserialize {
    my ($class, $data) = @_;

    my $io = Data::AMF::IO->new( data => $data );

    my $ver           = $io->read_u16;
    my $header_count  = $io->read_u16;
    my $message_count = $io->read_u16;

    my $parser = Data::AMF::Parser->new( version => $ver );

    my @headers;
    for my $i (1 .. $header_count) {
        my $name  = $io->read_utf8;
        my $must  = $io->read_u32;
        my $len   = $io->read_u32;
        my $value = $parser->parse_one($io);

        push @headers, Data::AMF::Header->new(
            name            => $name,
            must_understand => $must,
            length          => $len,
            value           => $value,
        );
    }

    my @messages;
    for my $i (1 .. $message_count) {
        my $target_uri   = $io->read_utf8;
        my $response_uri = $io->read_utf8;
        my $len          = $io->read_u32;

        my $data    = $io->read($len);
        my ($value) = $parser->parse($data);

        push @messages, Data::AMF::Message->new(
            target_uri   => $target_uri,
            response_uri => $response_uri,
            length       => $len,
            value        => $value,
        );
    }

    Data::AMF::Packet->new(
        version  => $ver,
        headers  => \@headers,
        messages => \@messages,
    );
}

1;

