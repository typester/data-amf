package Data::AMF::Parser;
use strict;
use warnings;

use Data::AMF::IO;

use constant PARSERS => [
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
    \&parse_unsupported,
    \&parse_recordset,
    \&parse_xml_document,
    \&parse_typed_object,
];

sub parse {
    my ($class, $data) = @_;

    my @res;
    my $io = ref($data) eq 'Data::AMF::IO' ? $data : Data::AMF::IO->new(data => $data);

    while (defined( my $marker = $io->read_u8 )) {
        my $p = PARSERS->[$marker] or die;
        push @res, $p->($io);
    }

    @res;
}

sub parse_one {
    my ($class, $data) = @_;

    my @res;
    my $io = ref($data) eq 'Data::AMF::IO' ? $data : Data::AMF::IO->new($data);

    my $marker = $io->read_u8;
    return unless defined $marker;

    my $p = PARSERS->[$marker] or die;
    $p->($io);
}

sub parse_number {
    my $io = shift;

    $io->read_double;
}

sub parse_boolean {
    my $io = shift;

    !!$io->read_u8;
}

sub parse_string {
    my $io = shift;

    $io->read_utf8;
}

sub parse_object {
    my $io = shift;

    my $obj = {};

    while (1) {
        my $len = $io->read_u16;
        if ($len == 0) {
            $io->read_u8;       # object-end marker
            last
        }
        my $key   = $io->read($len);
        my $value = Data::AMF::Parser->parse_one($io);

        $obj->{ $key } = $value;
    }

    $obj;
}

sub parse_movieclip {  }

sub parse_null {
    undef;
}

sub parse_undefined {
    undef;                      # XXX
}

sub parse_reference {
    my $io = shift;
    $io->read_u16;

    return;                     # XXX
}

sub parse_ecma_array {
    my $io = shift;

    my $count = $io->read_u32;
    parse_object($io);
}

sub parse_strict_array {
    my $io = shift;

    my $count = $io->read_u32;

    my @res;
    for (1 .. $count) {
        push @res, Data::AMF::Parser->parse_one($io);
    }

    \@res;
}

sub parse_date {
    my $io = shift;

    my $msec = $io->read_double;
    my $tz   = $io->read_s16;

    $msec;
}

sub parse_long_string {
    my $io = shift;

    $io->read_utf8_long;
}

sub parse_unsupported { }
sub parse_recordset { }

sub parse_xml_document {
    parse_long_string(shift)  # XXX
}

sub parse_typed_object {
    my $io = shift;

    my $class = $io->read_utf8;
    parse_object($io);
}

1;

