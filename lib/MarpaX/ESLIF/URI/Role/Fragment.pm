package MarpaX::ESLIF::URI::Role::Fragment;

# ABSTRACT: URI Fragment Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/Undef Str/;

has 'fragment' => (is => 'rwp', isa => Undef|Str, required => 1);

#
# Used for clone
#
sub Fragment_fields  { qw/fragment/ }

1;
