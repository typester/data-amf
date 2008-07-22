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

has source => (
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

=head1 NAME

Data::AMF::Message - AMF Message class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head2 result

=head2 error

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;

