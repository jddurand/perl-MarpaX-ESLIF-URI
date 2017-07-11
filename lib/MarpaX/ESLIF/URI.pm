use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI;

# ABSTRACT: URI decoder as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use MarpaX::ESLIF::URI::Grammar;

#
# Default is <URI reference>
#
sub new {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'URI reference', input => $args[0]), __PACKAGE__)
  } else {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'URI reference', @args), __PACKAGE__)
  }
}

#
# Though one can build an <absolute URI> as well
#
sub new_abs {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'absolute URI', input => $args[0]), __PACKAGE__)
  } else {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'absolute URI', @args))
  }
}

1;
