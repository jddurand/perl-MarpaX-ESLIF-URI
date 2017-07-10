package MarpaX::ESLIF::URI::Impl::Default;

# ABSTRACT: URI default implementation

# AUTHORITY

# VERSION

use Moo;
use strictures 2;
use Types::Standard qw/Str Undef/;

has scheme    => (is => 'rwp', isa => Str);
has authority => (is => 'rwp', isa => Str|Undef);
has path      => (is => 'rwp', isa => Str);
has query     => (is => 'rwp', isa => Str|Undef);
has fragment  => (is => 'rwp', isa => Str|Undef);

sub BUILD {
}

with qw/MarpaX::ESLIF::URI::Role/;

1;
