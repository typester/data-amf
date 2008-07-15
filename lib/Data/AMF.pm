package Data::AMF;
use 0.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use Data::AMF::Parser;
use Data::AMF::Packet;

sub serialize {
    my ($class, @obj) = @_;

}

sub deserialize {
    
}

sub serialize_packet {
    my $class = shift;

    my $packet = Data::AMF::Packet->new(@_);
    $packet->serialize;
}

sub deserialize_packet {
    my ($class, $data) = @_;
    Data::AMF::Packet->deserialize($data);
}

=head1 NAME

Data::AMF - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

use Data::AMF;

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
