package MarpaX::ESLIF::URI::Role::URI_reference;

# ABSTRACT: URI Reference Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/Str/;

has 'URI_reference' => (is => 'rwp', isa => Str, required => 1);

#
# Used for clone
#
sub URI_reference_fields { qw/URI_reference/ }

1;
