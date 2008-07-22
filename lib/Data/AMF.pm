package Data::AMF;
use 0.008001;
use Moose;

our $VERSION = '0.01';

use Data::AMF::Parser;
use Data::AMF::Formatter;

has version => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 0 },
);

has parser => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Data::AMF::Parser->new( version => $self->version );
    },
);

has formatter => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Data::AMF::Formatter->new( version => $self->version );
    },
);

__PACKAGE__->meta->make_immutable;

sub serialize {
    my $self = shift;
    $self->formatter->format(@_);
}

sub deserialize {
    my $self = shift;
    $self->parser->parse(@_);
}

=head1 NAME

Data::AMF - serialize/deserialize AMF data and packet.

=head1 SYNOPSIS

use Data::AMF;

    my $amf0 = Data::AMF->new( version => 0 );
    my $amf3 = Data::AMF->new( version => 3 );
    
    # AMF to Perl Object
    my @obj = $amf0->deserialize($data);
    
    # Perl Object to AMF
    my $data = $amf0->serialize($obj);

=head1 DESCRIPTION

=head1 METHOD

=head2 new

=head2 serialize

=head2 deserialize

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
