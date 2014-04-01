requires 'parent', 0;
requires 'Future', '>= 0.24';
requires 'IO::Async', '>= 0.54';
requires 'Protocol::SMTP', '>= 0.001';

recommends 'IO::Async::Resolver::DNS', '>= 0.04';

on 'test' => sub {
	requires 'Test::More', '>= 0.98';
	requires 'Test::Fatal', '>= 0.010';
	requires 'Test::Refcount', '>= 0.07';
};

