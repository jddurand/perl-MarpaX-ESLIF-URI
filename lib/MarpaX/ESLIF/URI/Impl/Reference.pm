package MarpaX::ESLIF::URI::Impl::Reference;

# ABSTRACT: Reference URI implementation

# AUTHORITY

# VERSION

use Moo;
use strictures 2;

extends qw/MarpaX::ESLIF::URI::Impl::Default/;

has '+start' => (default => sub { 'URI reference' });

with qw/MarpaX::ESLIF::URI::Role/;

1;
