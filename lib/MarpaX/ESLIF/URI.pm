package MarpaX::ESLIF::URI;

# ABSTRACT: URI as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use MarpaX::ESLIF::URI::_generic;
use Class::Load qw/load_class/;
use SUPER;

my $re_scheme = qr/[A-Za-z][A-Za-z0-9+\-.]*/;

sub new {
  my ($class, $str, $scheme) = @_;

  my $self;
  if (defined($str)) {
      $str = "$str";
      if ($str =~ /^($re_scheme):/) {
          $scheme = $1
      } else {
          if (defined($scheme) && ($scheme =~ /^$re_scheme$/)) {
              $str = "$scheme:$str"
          } else {
              $scheme = undef
          }
      }
  } else {
      $scheme = undef
  }

  if (defined($scheme)) {
      #
      # If defined, here $scheme is guaranteed to contain only ASCII characters
      #
      my $lc_scheme = lc($scheme);
      $self = eval { load_class("MarpaX::ESLIF::URI::$lc_scheme")->new($str) }
  }
  #
  # Fallback to _generic
  #
  $self //= MarpaX::ESLIF::URI::_generic->new($str)
}

1;
