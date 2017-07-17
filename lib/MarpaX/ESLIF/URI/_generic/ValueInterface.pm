use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic::ValueInterface;
use vars qw/$AUTOLOAD/;

sub new {
  my ($class) = @_;
  bless {}, $class          # C.f. AUTOLOAD
}

#
# Value Interface required methods
#
sub isWithHighRankOnly {     1 } # When there is the rank adverb: highest ranks only ?
sub isWithOrderByRank  {     1 } # When there is the rank adverb: order by rank ?
sub isWithAmbiguous    {     0 } # Allow ambiguous parse ?
sub isWithNull         {     0 } # Allow null parse ?
sub maxParses          {     0 } # Maximum number of parse tree values - meaningless when !isWithAmbiguous
sub setResult          {       } # No-op here
sub getResult          { $_[0] } # Result

#
# Grammar specific actions
#
sub _segment {
    my ($self, @args) = @_;

    my $rc = join('', map { $_ // '' } @args);
    push(@{$self->{segments}}, $rc);
    $rc
}

# Specific value methods. Default is to NOT decode.
sub _pct_encoded {
    my ($self, $pctcharacter, $hex1, $hex2) = @_;

    chr(hex("$hex1$hex2"))
}

sub _field {
    my ($self, $what, @args) = @_;
    $self->{$what} = join('', map { $_ // '' } @args)
}

#
# The hash it automatically generated
#
sub AUTOLOAD {
  my $field = $AUTOLOAD;
  $field =~ s/.*:://;
  shift->_field($field, @_)
}

1;