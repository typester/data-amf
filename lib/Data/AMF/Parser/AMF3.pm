package Data::AMF::Parser::AMF3;
use strict;
use warnings;

use Data::AMF::IO;
use UNIVERSAL::require;

# ----------------------------------------------------------------------
# Class Constants
# ----------------------------------------------------------------------

use constant AMF0_TYPES =>
[
	'number',
	'boolean',
	'string',
	'object',
	'movieclip',
	'null',
	'undefined',
	'reference',
	'ecma_array',
	'object_end',
	'strict_array',
	'date',
	'long_string',
	'unsupported',
	'recordset',
	'xml_document',
	'typed_object',
	'avmplus_object',
];

use constant AMF3_TYPES =>
[
	'amf3_undefined',
	'amf3_null',
	'amf3_false',
	'amf3_true',
	'amf3_integer',
	'number',
	'amf3_string',
	'amf3_xml_document',
	'amf3_date',
	'amf3_array',
	'amf3_object',
	'amf3_xml',
	'amf3_byte_array',
];

use constant AMF3_INTEGER_MAX => "268435455";

# ----------------------------------------------------------------------
# Class Methods
# ----------------------------------------------------------------------

sub parse
{
	my ($class, $data) = @_;
	
	my $self = $class->new;
	$self->{'io'} = Data::AMF::IO->new(data => $data);
	
	return $self->read;
}

# ----------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------

sub new
{
	my $class = shift;
	my $self = bless {
		io => undef,
		amf0_stored_objects => [],
		class_member_defs => {},
		stored_strings => [],
		stored_objects => [],
		stored_defs => [],
		@_
	}, $class;
	return $self;
}

# ----------------------------------------------------------------------
# Properties
# ----------------------------------------------------------------------

sub io { return $_[0]->{'io'} }

# ----------------------------------------------------------------------
# Methods
# ----------------------------------------------------------------------

sub read
{
	my $self = shift;
	
	my @res;
	
	while (defined(my $marker = $self->io->read_u8))
	{
		my $method = 'read_' . AMF0_TYPES->[$marker] or die;
		push @res, $self->$method();
	}
	
	@res;
}

sub read_amf0
{
	my $self = shift;
	
	my $marker = $self->io->read_u8;
	return if not defined $marker;
	
	my $method = 'read_' . AMF0_TYPES->[$marker] or die;
	return $self->$method();
}

sub read_number
{
	my $self = shift;
	return $self->io->read_double;
}

sub read_boolean
{
	my $self = shift;	
	return $self->io->read_u8 ? 1 : 0;
}

sub read_string
{
	my $self = shift;	
	my $str = $self->io->read_utf8;
	return $str;
}

sub read_object
{
	my $self = shift;
	
	my $obj = {};
	push @{ $self->{'amf0_stored_objects'} }, $obj;
	
	while (1)
	{
		my $len = $self->io->read_u16;
		if ($len == 0)
		{
			$self->io->read_u8;	   # object-end marker
			return $obj;
		}
		my $key = $self->io->read($len);
		my $value = $self->read_amf0;
		
		$obj->{$key} = $value;
	}
	
	return $obj;
}

sub read_movieclip { }

sub read_null
{
	return undef;
}

sub read_undefined
{
	return undef;
}

sub read_reference
{
	my $self = shift;
	my $index = $self->io->read_u16;
	my $obj = $self->{'amf0_stored_objects'}->[$index];
	return $obj;
}

sub read_ecma_array
{
	my $self = shift;
	my $count = $self->io->read_u32;
	return $self->read_object;
}

sub read_strict_array
{
	my $self = shift;
	
	my $count = $self->io->read_u32;
	my @res;
	
	for (1 .. $count)
	{
		push @res, $self->read_amf0;
	}
	
	my $array = \@res;
	push @{ $self->{'amf0_stored_objects'} }, $array;
	
	return $array;
}

sub read_date
{
	my $self = shift;
	
	my $msec = $self->io->read_double;
	my $tz   = $self->io->read_s16;
	
	return $msec;
}

sub read_long_string
{
	my $self = shift;
	return $self->io->read_utf8_long;
}

sub read_unsupported { }
sub read_recordset { }

sub read_xml_document
{
	my $self = shift;
	return $self->read_long_string;
}

sub read_typed_object
{
	my $self = shift;
	my $class = $self->io->read_utf8;
	return $self->read_object;
}

sub read_avmplus_object
{
	my $self = shift;	
	return $self->read_amf3;
}

sub read_amf3
{
	my $self = shift;

	my $marker = $self->io->read_u8;
	return unless defined $marker;
	
	my $method = 'read_' . AMF3_TYPES->[$marker] or die;
	return $self->$method();
	
	#return thaw($self->io->data);
}

sub read_amf3_undefined
{
	return undef;
}

sub read_amf3_null
{
	Data::AMF::Type::Null->require;
	return Data::AMF::Type::Null->new;
}

sub read_amf3_false
{
	Data::AMF::Type::Boolean->require;
	return Data::AMF::Type::Boolean->new(0);
}

sub read_amf3_true
{
	Data::AMF::Type::Boolean->require;
	return Data::AMF::Type::Boolean->new(1);
}

sub read_amf3_integer
{
	my $self = shift;
	
	my $n = 0;
	my $b = $self->io->read_u8 || 0;
	my $result = 0;
	
	while (($b & 0x80) != 0 && $n < 3)
	{
		$result = $result << 7;
		$result = $result | ($b & 0x7f);
		$b = $self->io->read_u8 || 0;
		$n++;
	}
	
	if ($n < 3)
	{
		$result = $result << 7;
		$result = $result | $b;
	}
	else
	{
		# Use all 8 bits from the 4th byte
		$result = $result << 8;
		$result = $result | $b;
		
		# Check if the integer should be negative
		if ($result > AMF3_INTEGER_MAX)
		{
			# and extend the sign bit
			$result -= (1 << 29);
		}
	}
		
	return $result;
}

sub read_amf3_string
{
	my $self = shift;
	
	my $type = $self->read_amf3_integer();
	my $isReference = ($type & 0x01) == 0;

	if ($isReference)
	{
		my $reference = $type >> 1;
		if ($reference < @{ $self->{'stored_strings'} })
		{
			if (not defined $self->{'stored_strings'}->[$reference])
			{
				die "Reference to non existant object at index #{$reference}.";
			}
			
			return $self->{'stored_strings'}->[$reference];
		}
		else
		{
			die "Reference to non existant object at index #{$reference}.";
		}
	}
	else
	{
		my $length = $type >> 1;
		my $str;
		
		if ($length > 0)
		{
			$str = $self->io->read($length);
			push @{ $self->{'stored_strings'} }, $str;
		}
		
		return $str;
	}
}

sub read_amf3_xml_document
{
	my $self = shift;
	my $type = $self->read_amf3_integer();
	my $length = $type >> 1;
	my $obj = $self->io->read($length);
	push @{ $self->{'stored_objects'} }, $obj;
	return $obj;
}

sub read_amf3_date
{
	my $self = shift;
	
	my $type = $self->read_amf3_integer();
	my $isReference = ($type & 0x01) == 0;
	
	if ($isReference)
	{
		my $reference = $type >> 1;
		if ($reference < @{ $self->{'stored_objects'} })
		{
			if (not defined $self->{'stored_objects'}->[$reference])
			{
				die "Reference to non existant object at index #{$reference}.";
			}
			
			return $self->{'stored_objects'}->[$reference];
		}
		else
		{
			die "Reference to non existant object at index #{$reference}.";
		}
	}
	else
	{
		my $epoch = $self->io->read_double / 1000;
		
		DateTime->require;
		my $datetime = DateTime->from_epoch( epoch => $epoch );
		
		push @{ $self->{'stored_objects'} }, $datetime;
		return $datetime;
	}
}

sub read_amf3_array
{
	my $self = shift;
	
	my $type = $self->read_amf3_integer();
	my $isReference = ($type & 0x01) == 0;
	
	if ($isReference)
	{
		my $reference = $type >> 1;
		if ($reference < @{ $self->{'stored_objects'} })
		{
			if (not defined $self->{'stored_objects'}->[$reference])
			{
				die "Reference to non existant object at index #{$reference}.";
			}

			return $self->{'stored_objects'}->[$reference];
		}
		else
		{
			die "Reference to non existant object at index #{$reference}.";
		}
	}
	else
	{
		my $length = $type >> 1;
		my $key = $self->read_amf3_string();
		my $array;
		
		if (defined $key)
		{
			$array = {};
			push @{ $self->{'stored_objects'} }, $array;
			
			while(length $key)
			{
				my $value = $self->read_amf3();
				$array->{$key} = $value;
				$key = $self->read_amf3_string();
			}
			
			for (0 .. $length - 1)
			{
				$array->{$_} = $self->read_amf3();
			}
		}
		else
		{
			$array = [];
			push @{ $self->{'stored_objects'} }, $array;
			
			for (0 .. $length - 1)
			{
				push @{ $array }, $self->read_amf3();
			}
		}
		
		return $array;
	}
}

sub read_amf3_object
{
	my $self = shift;
	
	my $type = $self->read_amf3_integer();
	my $isReference = ($type & 0x01) == 0;
	
	if ($isReference)
	{
		my $reference = $type >> 1;
		
		if ($reference < @{ $self->{'stored_objects'} })
		{
			if (not defined $self->{'stored_objects'}->[$reference])
			{
				die "Reference to non existant object at index #{$reference}.";
			}
			
			return $self->{'stored_objects'}->[$reference];
		}
		else
		{
			warn "Reference to non existant object at index #{$reference}.";
		}
	}
	else
	{
		my $class_type = $type >> 1;
		my $class_is_reference = ($class_type & 0x01) == 0;
		my $class_definition;
		
		if ($class_is_reference)
		{
			my $class_reference = $class_type >> 1;
			
			if ($class_reference < @{ $self->{'stored_defs'} })
			{
				$class_definition = $self->{'stored_defs'}->[$class_reference];
			}
			else
			{
				die "Reference to non existant object at index #{$class_reference}.";
			}
		}
		else
		{
			my $as_class_name = $self->read_amf3_string();
			my $externalizable = ($class_type & 0x02) != 0;
			my $dynamic = ($class_type & 0x04) != 0;
			my $attr_count = $class_type >> 3;
			
			my $members = [];
			for (1 .. $attr_count)
			{
				push @{ $members }, $self->read_amf3_string();
			}
			
			$class_definition =
			{
				"as_class_name" => $as_class_name,
				"members" => $members,
				"externalizable" => $externalizable,
				"dynamic" => $dynamic
			};
			
			push @{ $self->{'stored_defs'} }, $class_definition;
		}
		
		my $action_class_name = $class_definition->{'as_class_name'};
		my ($skip_mapping, $obj);
		
		if ($action_class_name && $action_class_name =~ /flex\.messaging/)
		{
			$obj = {};
			$obj->{'_explicitType'} = $action_class_name;
			$skip_mapping = 1;
		}
		else
		{
			$obj = {};
			$skip_mapping = 0;
		}
		
		my $obj_position = @{ $self->{'stored_objects'} };
		push @{ $self->{'stored_objects'} }, $obj;
		
		if ($class_definition->{'externalizable'})
		{
			$obj = $self->read_amf3();
		}
		else
		{
			for my $key (@{ $class_definition->{'members'} })
			{
				$obj->{$key} = $self->read_amf3();
			}
		}
		
		if ($class_definition->{'dynamic'})
		{
			my $key;
			while (($key = $self->read_amf3_string()) && length $key != 0) {
				$obj->{$key} = $self->read_amf3();
			}
		}
		
		return $obj;
	}
}

sub read_amf3_xml
{
	my $self = shift;
	my $type = $self->read_amf3_integer();
	my $length = $type >> 1;
	my $obj = $self->io->read($length);
	
	XML::LibXML->require;
	my $xml = XML::LibXML->new()->parse_string($obj);
	
	push @{ $self->{'stored_objects'} }, $xml;
	return $xml;
}

sub read_amf3_byte_array
{
	my $self = shift;
	
	my $type = $self->read_amf3_integer();
	my $isReference = ($type & 0x01) == 0;
	
	if ($isReference)
	{
		my $reference = $type >> 1;
		if ($reference < @{ $self->{'stored_objects'} })
		{
			if (not defined $self->{'stored_objects'}->[$reference])
			{
				die "Reference to non existant object at index #{$reference}.";
			}
			
			return $self->{'stored_objects'}->[$reference];
		}
		else
		{
			die "Reference to non existant object at index #{$reference}.";
		}
	}
	else
	{
		my $length = $type >> 1;
		my @obj = unpack('C' . $length, $self->io->read($length));
		
		Data::AMF::Type::ByteArray->require;
		my $obj = Data::AMF::Type::ByteArray->new(\@obj);
		
		push @{ $self->{'stored_objects'} }, $obj;
		return $obj;
	}
}

1;

