package Data::AMF;
use 0.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use Data::AMF::Parser;
use Data::AMF::Packet;

sub serialize {
    
}

sub deserialize {
    
}

sub serialize_packet {

}

sub deserialize_pakcet {

}

=head1 NAME

Data::AMF - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

=cut

use Data::AMF;

my $packet = Data::AMF->from_packet($amf_packet);

for my $message (@{ $packet->messages }) {

    my $result = dispatch_remoting( $message->target_uri );
    
}

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
