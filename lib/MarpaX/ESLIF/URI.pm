package MarpaX::ESLIF::URI;

# ABSTRACT: URI as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use MarpaX::ESLIF::URI::_generic;
use Class::Load qw/load_class/;
use SUPER;

sub new {
  my ($class, $uri) = @_;

  croak "Usage: $class->new(\$uri)" unless $uri;
  #
  # scheme is always a well define, ASCII only, thingy at the very beginning:
  #
  if ($uri =~ /^[A-Za-z][A-Za-z0-9+\-.]*/p) {
      my $lc_scheme = lc(${^MATCH});
      eval { load_class("MarpaX::ESLIF::URI::$lc_scheme")->new($uri) } // MarpaX::ESLIF::URI::_generic->new($uri)
  } else {
      MarpaX::ESLIF::URI::_generic->new($uri)
  }
}

1;
