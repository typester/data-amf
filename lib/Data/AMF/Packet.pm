package Data::AMF::RequestPacket;
use strict;
use warnings;

use Data::AMF::Parser;
use Data::AMF::IO;

sub deserialize {
    my ($class, $data) = @_;

    my $io = Data::AMF::IO->new( data => $data );

    my $ver           = $io->read_u16;
    my $header_count  = $io->read_u16;
    my $message_count = $io->read_u16;

    for my $i (1 .. $header_count) {
        my $name  = $io->read_utf8;
        my $must  = $io->read_u32;
        my $len   = $io->read_u32;
        my $value = 
    }
}

1;

