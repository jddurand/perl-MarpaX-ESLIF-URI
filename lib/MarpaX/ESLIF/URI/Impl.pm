package MarpaX::ESLIF::URI::Impl;

# ABSTRACT: URI Implementation

# AUTHORITY

# VERSION

use Moo;
use strictures 2;

has start     => (is => 'ro', required => 1);
has input     => (is => 'ro', required => 1);
has encoding  => (is => 'ro');
has scheme    => (is => 'rwp');
has authority => (is => 'rwp');
has path      => (is => 'rwp');
has query     => (is => 'rwp');
has fragment  => (is => 'rwp');

with 'MarpaX::ESLIF::URI::Role';

1;
