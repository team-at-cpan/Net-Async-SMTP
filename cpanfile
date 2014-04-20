requires 'parent', 0;
requires 'Future', '>= 0.24';
requires 'IO::Socket::SSL', 0;
requires 'IO::Async', '>= 0.54';
requires 'Protocol::SMTP', '>= 0.001';

recommends 'IO::Async::SSL', '>= 0.14';
recommends 'IO::Async::Resolver::DNS', '>= 0.04';
recommends 'Email::Simple', 0;

on 'test' => sub {
	requires 'Test::More', '>= 0.98';
	requires 'Test::Fatal', '>= 0.010';
};

