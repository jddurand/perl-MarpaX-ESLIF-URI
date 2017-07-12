package MarpaX::ESLIF::URI::Role::Query;

# ABSTRACT: URI Query Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/Undef Str/;

has 'query' => (is => 'rwp', isa => Undef|Str, required => 1);

#
# Used for clone
#
sub Query_fields  { qw/query/ }

1;
