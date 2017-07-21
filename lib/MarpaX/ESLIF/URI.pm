package MarpaX::ESLIF::URI;

# ABSTRACT: URI as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Load qw/load_class/;
use MarpaX::ESLIF::URI::_generic;

my $re_scheme = qr/[A-Za-z][A-Za-z0-9+\-.]*/;

sub new {
  my ($class, $str, $scheme) = @_;

  croak '$str must be defined' unless defined($str);
  
  my $self;
  $str = "$str";
  if ($str =~ /^($re_scheme):/) {
      $scheme = $1
  } elsif (defined($scheme) && ($scheme =~ /^$re_scheme$/)) {
      $str = "$scheme:$str"
  }

  if (defined($scheme)) {
      #
      # If defined, $scheme is guaranteed to contain only ASCII characters
      #
      my $lc_scheme = lc($scheme);
      $self = eval { load_class("MarpaX::ESLIF::URI::$lc_scheme")->new(_origin => $str) }
  }
  #
  # Fallback to _generic
  #
  $self //= MarpaX::ESLIF::URI::_generic->new(_origin => $str)
}

=head1 NOTES

Percent-encoded characters are decoded to ASCII characters corresponding to every percent-encoded byte.

=head1 SEE ALSO

L<MarpaX::ESLIF::URI::_generic>, L<MarpaX::ESLIF::URI::_file>

=cut

1;
