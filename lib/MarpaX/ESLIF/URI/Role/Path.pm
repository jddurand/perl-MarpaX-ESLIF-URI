package MarpaX::ESLIF::URI::Role::Path;

# ABSTRACT: URI Path Role as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;
use Types::Standard qw/ArrayRef Str/;

has 'path'     => (is => 'rwp', isa => Str, required => 1);
has 'segments' => (is => 'rwp', isa => ArrayRef[Str], required => 1);

#
# Used for clone
#
sub Path_fields  { qw/path segments/ }

1;
