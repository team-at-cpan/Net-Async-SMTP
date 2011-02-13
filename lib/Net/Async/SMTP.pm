package Net::Async::SMTP;
use strict;
use warnings;

our $VERSION = '0.001';

1;

__END__

=head1 NAME

Net::Async::SMTP - asynchronous SMTP handling based on L<Protocol::SMTP> and L<IO::Async::Protocol::Stream>.

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

# Automatically retrieve any new messages that arrive on the server
	on_send_ready => sub {
		my ($self, $id) = @_;
		$self->send(
			from		=> '',
			recipient	=> '',
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

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

