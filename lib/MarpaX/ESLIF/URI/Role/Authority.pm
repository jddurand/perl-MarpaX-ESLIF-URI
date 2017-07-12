package MarpaX::ESLIF::URI::Role::Authority;

# ABSTRACT: URI Authority Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/Undef Str/;
use Types::Common::Numeric qw/PositiveInt/;

has 'authority' => (is => 'rwp', isa => Undef|Str,         required => 1);
has 'userinfo'  => (is => 'rwp', isa => Undef|Str,         required => 1);
has 'host'      => (is => 'rwp', isa => Undef|Str,         required => 1);
has 'port'      => (is => 'rwp', isa => Undef|PositiveInt, required => 1);

#
# Used for clone
#
sub Authority_fields  { qw/authority userinfo host port/ }

1;
