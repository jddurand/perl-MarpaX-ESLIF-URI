package MarpaX::ESLIF::URI;

use MarpaX::ESLIF::URI::Impl;

# ABSTRACT: URI implementation

# AUTHORITY

# VERSION

#
# Default is <URI reference>
#
sub new {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return MarpaX::ESLIF::URI::Impl->new(start => 'URI reference', input => $args[0])
  } else {
    return MarpaX::ESLIF::URI::Impl->new(start => 'URI reference', @args)
  }
}

#
# Though one can build an <absolute URI> as well
#
sub new_abs {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return MarpaX::ESLIF::URI::Impl->new(start => 'absolute URI', input => $args[0])
  } else {
    return MarpaX::ESLIF::URI::Impl->new(start => 'absolute URI', @args)
  }
}

1;
