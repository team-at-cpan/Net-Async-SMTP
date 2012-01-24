#!/usr/bin/perl 
use strict;
use warnings;

use IO::Async::Loop;
use IO::Async::Timer::Countdown;
use Net::Async::SMTP::Client;

# Use one of the Perl Email Project modules for handling email.
use Email::Simple;

# Standard event loop creation
my $loop = IO::Async::Loop->new;

# We create a new client instance, passing the information needed to connect - when the event loop starts, this
# should make the connection for us and call the on_authenticated callback.
my $smtp = Net::Async::SMTP::Client->new(
	# Set the debug flag to 1 to see lots of tedious detail about what's happening.
	debug			=> 1,
	host			=> $ENV{NET_ASYNC_SMTP_SERVER},
	service			=> $ENV{NET_ASYNC_SMTP_PORT} || 'smtp',
	user			=> $ENV{NET_ASYNC_SMTP_USER},
	pass			=> $ENV{NET_ASYNC_SMTP_PASS},
	on_authenticated	=> \&check_server,
);

$loop->add($smtp);

$loop->loop_forever;
exit 0;

sub check_server {
	$smtp->send(
		from	=> 'cpan@entitymodel.com',
		to	=> 'cpan@entitymodel.com',
		data	=> sub {

		},
		on_queued	=> sub {
			my ($self, $id) = @_;
			ok($id, 'have message ID ' . $id);
		}
	);
}

