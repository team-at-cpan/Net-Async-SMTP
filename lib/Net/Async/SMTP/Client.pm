package Net::Async::SMTP::Client;
use strict;
use warnings;
use parent qw{IO::Async::Protocol::LineStream};

use Socket;

=head1 NAME

Net::Async::SMTP::Client - asynchronous SMTP client based on L<Protocol::SMTP::Client> and L<IO::Async::Protocol::Stream>.

=head1 SYNOPSIS

 use IO::Async::Loop;
 use Net::Async::SMTP;
 my $loop = IO::Async::Loop->new;
 my $imap = Net::Async::SMTP::Client->new(
 	loop => $loop,
	host => 'mailserver.com',
	service => 1025, # custom port number example
	user => 'user@mailserver.com',
	pass => 'password',

	on_authenticated => sub {
		my ($self, $id) = @_;
		$self->send(
			from		=> '',
			to		=> '',
			data		=> sub {

			}
		);
	},

# Display the subject whenever we have a successful FETCH command
	on_queued => sub {
		my ($self, $id) = @_;
		warn "Queued as $msg";
	},
 );
 $loop->loop_forever;

=head1 DESCRIPTION

Provides support for communicating with SMTP servers under L<IO::Async>.

See L<Protocol::SMTP> for more details on this implementation of SMTP, and RFC822 and similar
for the official protocol specification.

=head1 METHODS

=cut

=head2 new

Instantiate a new object. Will add to the event loop if the loop parameter is passed.

=cut

sub new {
	my $class = shift;
	my %args = @_;

# Clear any options that will cause the parent class to complain
	my $loop = delete $args{loop};

	my $self = $class->SUPER::new( %args );

# Automatically add to the event loop if we were passed one
	$loop->add($self) if $loop;
	return $self;
}

=head2 on_read_line

Pass any new data into the protocol handler.

=cut

sub on_read_line {
	my ($self, $line) = @_;
	$self->debug("Have line [$line]");
	my $remaining = $self->on_single_line($line);
	return 1 unless $remaining;

# Switch to multi-line (fixed data size) mode
	return $self->_capture_weakself(sub {
		my $self = shift;
		my ($stream, $buffref, $closed) = @_;

		$self->debug("Have length [" . length($$buffref) . "] expecting $remaining");
		# Allow buffer to build up until we have the entire response
		return 0 unless length $$buffref >= $remaining;

		# Extract full buffer and pass it on to the multiline handler
		my $data = substr($$buffref, 0, $remaining, '');
		$self->on_multi_line($data);

		# On completion drop back to the previous handler
		delete $self->{multiline};
		return undef;
	});
}

=head2 configure

Apply callbacks and other parameters, preparing state for event loop start.

=cut

sub configure {
	my $self = shift;
	my %args = @_;

# Debug flag is used to control the copious amounts of data that we dump out when tracing
	if(exists $args{debug}) {
		$self->{debug} = delete $args{debug} ? 1 : 0;
	}

	# die "No host provided" unless $args{host} || $self->{transport};
	foreach (qw{host service user pass ssl tls}) {
		$self->{$_} = delete $args{$_} if exists $args{$_};
	}

	if( exists $args{idle_timeout} ) {
		$self->{idle_timer}->configure( delay => delete $args{idle_timeout} );
	}


# Don't think I like this much, but didn't want the list of callbacks held here
	# %args = $self->Protocol::SMTP::Client::configure(%args);

	$self->SUPER::configure(%args);
}

sub on_user { shift->{user} }
sub on_pass { shift->{pass} }

=head2 on_connection_established

Prepare and activate a new transport.

=cut

sub on_connection_established {
	my $self = shift;
	my $sock = shift;
	my $transport = IO::Async::Stream->new(handle => $sock)
		or die "No transport?";
	$self->configure(transport => $transport);
	$self->debug("Have transport " . $self->transport);
}

=head2 on_starttls

Upgrade the underlying stream to use TLS.

=cut

sub on_starttls {
	my $self = shift;
	$self->debug("Upgrading to TLS");

	require IO::Async::SSLStream;

	$self->SSL_upgrade(
		on_upgraded => $self->_capture_weakself(sub {
			my ($self) = @_;
			$self->debug("TLS upgrade complete");

			$self->{tls_enabled} = 1;
			$self->get_capabilities;
		}),
		on_error => sub { die "error @_"; }
	);
}

=head2 _add_to_loop

Set up the connection automatically when we are added to the loop.

TODO: this is probably the wrong way to go about things, move this somewhere more appropriate.

TODO(pe): Ish... It would be nice if the IO::Async::Protocol could manage an
automatic ->connect call

=cut

sub _add_to_loop {
	my $self = shift;
	$self->SUPER::_add_to_loop(@_);
	$self->connect(
		host    => $self->{host},
		service => $self->{service},
	);
}

=head2 connect

=cut

sub connect {
	my $self = shift;
	my %args = @_;

	my $on_connected = delete $args{on_connected};
#	$self->state(Protocol::SMTP::ConnectionClosed);
	my $host = exists $args{host} ? delete $args{host} : $self->{host};
	$self->SUPER::connect(
		service		=> 'smtp',
		%args,
		host		=> $host,
		socktype	=> SOCK_STREAM,
		on_resolve_error => sub {
			die "Resolution failed for $host";
		},
		on_connect_error => sub {
			die "Could not connect to $host";
		},
		on_connected => sub {
			my ($self, $sock) = @_;
#			$self->state(Protocol::SMTP::ConnectionEstablished, $self->transport->read_handle);
			$on_connected->($self) if $on_connected;
		}
	);
}

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

