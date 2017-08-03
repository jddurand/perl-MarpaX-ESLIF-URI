use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI;

# ABSTRACT: URI as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Load qw/load_class/;
use MarpaX::ESLIF::URI::_generic;

my $re_scheme = qr/[A-Za-z][A-Za-z0-9+\-.]*/;

=head2 $class->new($str, $scheme)

Returns a instance that is a MarpaX::ESLIF::URI::$scheme representation of C<$str>, when C<$scheme> defaults to C<_generic> if there is no specific C<$scheme> implementation, or if the later fails.

=cut

sub new {
  my ($class, $str, $scheme) = @_;

  croak '$str must be defined' unless defined($str);
  
  my $self;
  $str = "$str";
  if ($str =~ /^($re_scheme):/o) {
      $scheme = $1
  } elsif (defined($scheme) && ($scheme =~ /^$re_scheme$/o)) {
      $str = "$scheme:$str"
  }

  if (defined($scheme)) {
      #
      # If defined, $scheme is guaranteed to contain only ASCII characters
      #
      my $lc_scheme = lc($scheme);
      $self = eval { load_class("MarpaX::ESLIF::URI::$lc_scheme")->new($str) }
  }
  #
  # Fallback to _generic
  #
  $self //= MarpaX::ESLIF::URI::_generic->new($str)
}

=head1 NOTES

Percent-encoded characters are decoded to ASCII characters corresponding to every percent-encoded byte.

=head1 SEE ALSO

L<MarpaX::ESLIF::URI::_generic>, L<MarpaX::ESLIF::URI::_file>

=cut

1;
