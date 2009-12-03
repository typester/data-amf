package Data::AMF::Type::ByteArray;
use strict;
use warnings;

sub new
{
	my $class = shift;
	my $self = bless { data => $_[0] }, $class;
	return $self;
}

sub data
{
	my $self = shift;
	
	if(@_)
	{
		$self->{'data'} = $_[0];
	}
	
	return $self->{'data'};
}

1;
