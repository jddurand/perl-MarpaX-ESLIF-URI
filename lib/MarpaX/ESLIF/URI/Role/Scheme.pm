package MarpaX::ESLIF::URI::Role::Scheme;

# ABSTRACT: URI Scheme Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/Undef Str/;

has 'scheme' => (is => 'rwp', isa => Undef|Str, required => 1);

#
# Used for clone
#
sub Scheme_fields  { qw/scheme/ }

1;
