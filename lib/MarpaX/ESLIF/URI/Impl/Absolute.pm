package MarpaX::ESLIF::URI::Impl::Absolute;

# ABSTRACT: Absolute URI implementation

# AUTHORITY

# VERSION

use Moo;
use strictures 2;

extends qw/MarpaX::ESLIF::URI::Impl::Default/;

has '+start' => (is => 'ro', default => sub { 'absolute URI' });

with qw/MarpaX::ESLIF::URI::Role/;

1;
