package Net::Async::SMTP;
# ABSTRACT: SMTP support for IO::Async
use strict;
use warnings;

our $VERSION = '0.003';

=head1 NAME

Net::Async::SMTP - email sending with IO::Async

=head1 SYNOPSIS

# EXAMPLE: examples/synopsis.pl

=head1 DESCRIPTION

Provides basic email sending capability for L<IO::Async>, using
the L<Protocol::SMTP> implementation.

See L<Protocol::SMTP/DESCRIPTION> for a list of supported features
and usage instructions.

This class does nothing - use L<Net::Async::SMTP::Client> for
sending email.

=cut

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2010-2014. Licensed under the same terms as Perl itself.

