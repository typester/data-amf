package Data::AMF::Remoting;
use strict;
use warnings;

use Data::AMF::Message;
use Data::AMF::Packet;

use constant CLIENT_PING_OPERATION => 5;

sub new
{
	my $class = shift;	
	
	my $properties =
	{
		source => undef,
		data => undef,
		headers_did_process => sub {},
		message_did_process => sub {},
		@_
	};
	
	return bless $properties, $class;
}

sub data { $_[0]->{'data'} }

sub run
{
	my $self = shift;
	
	my $request = Data::AMF::Packet->deserialize($self->{'source'});
	
	my @headers = @{ $request->headers };
	@headers = $self->{'headers_did_process'}->(@headers);
	
	
	my @messages;
	
	for my $message (@{ $request->messages })
	{
		my $target_uri = $message->target_uri;
		
		# RemoteObject
		if (not defined $target_uri or $target_uri eq 'null')
		{	
			my $type = $message->value->[0]->{'_explicitType'};
			my $source = $message->value->[0]->{'source'};
			my $operation = $message->value->[0]->{'operation'};
			
			if (    $type eq 'flex.messaging.messages.CommandMessage'
				and $operation eq CLIENT_PING_OPERATION)
			{
				push @messages, $message->result($message->value->[0]);
			}
			elsif ($type eq 'flex.messaging.messages.RemotingMessage')
			{
				$target_uri = '';
				
				if (defined $source and $source ne '')
				{
					$target_uri .= $source . '.';
				}
				
				if (defined $operation and $operation ne '')
				{
					$target_uri .= $operation;
				}
				
				my $res = $self->{'message_did_process'}->(
					Data::AMF::Message->new(
						target_uri => $target_uri,
						response_uri => '',
						value => $message->value->[0]->{'body'}
					)
				);
				
				push @messages, $message->result({
					correlationId => $message->value->[0]->{'messageId'},
					messageId => undef,
					clientId => undef,
					destination => '',
					timeToLive => 0,
					timestamp => 0,
					body => $res,
					headers => {},
					_explicitType => 'flex.messaging.messages.AcknowledgeMessage'
				});
			}		
			else
			{
				die "Recived unsupported message.";
			}
		}
		# Net Connection
		else
		{			
			my $res = $self->{'message_did_process'}->($message);
			push @messages, $message->result($res);
		}
	}
	
	my $response = Data::AMF::Packet->new(
		version  => $request->version,
		headers  => \@headers,
		messages => \@messages,
	);
	
	$self->{'data'}  = $response->serialize;
	
	return $self;
}

1;
