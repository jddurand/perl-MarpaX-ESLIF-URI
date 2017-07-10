package MarpaX::ESLIF::URI::Impl::Default;

# ABSTRACT: URI default implementation

# AUTHORITY

# VERSION

use Moo;
use strictures 2;

has start     => (is => 'ro', default => sub { 'URI reference' });
has input     => (is => 'ro', required => 1);
has encoding  => (is => 'ro', default => sub { });
has scheme    => (is => 'rwp');
has authority => (is => 'rwp');
has path      => (is => 'rwp');
has query     => (is => 'rwp');
has fragment  => (is => 'rwp');

1;
