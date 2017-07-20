use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic::ValueInterface;
use vars qw/$AUTOLOAD/;
use Class::Method::Modifiers qw/fresh/;

sub new {
    my ($class, $attribute_defaults) = @_;               # %attribute_defaults is optional

    $attribute_defaults = {} unless ref($attribute_defaults) eq 'HASH';

    bless
    {
        map {
            my $value = $attribute_defaults->{$_};
            $_ => ref($value) eq 'CODE' ? $value->() : $value
        } keys %{$attribute_defaults}
    }, $class
}

# --------------------------------
# Value Interface required methods
# --------------------------------
sub isWithHighRankOnly {     1 } # When there is the rank adverb: highest ranks only ?
sub isWithOrderByRank  {     1 } # When there is the rank adverb: order by rank ?
sub isWithAmbiguous    {     0 } # Allow ambiguous parse ?
sub isWithNull         {     0 } # Allow null parse ?
sub maxParses          {     0 } # Maximum number of parse tree values - meaningless when !isWithAmbiguous
sub setResult          {       } # No-op here
sub getResult          { $_[0] } # Result

# ----------------------
# Specific value methods
# ----------------------
#
# This _pct_encoded method guarantees that the output is a sequence of ASCII characters
# even if the UTF-8 flag would be set. For instance sequence %ce%a3 will be
# seen as "\x{ce}\x{a3}" in the resulting string, and NOT "\x{cea3}".
#
sub _pct_encoded {
    my ($self, undef, $hex1, $hex2) = @_;

    { origin => join('', '%', $hex1->{origin}, $hex2->{origin}), decode => chr(hex(join('', $hex1->{decode}, $hex2->{decode}))) }
}
#
# Pushes segments in a _segment[] array
#
sub _segment {
    my ($self, @args) = @_;

    my $concat = $self->_concat(@args);
    push(@{$self->{segments}->{origin}}, $concat->{origin});
    push(@{$self->{segments}->{decode}}, $concat->{decode});
    $concat
}
#
# Exactly the same as ESLIF's ::concat built-in, but revisited
# to work on original and decoded strings at the same time
#
sub _concat {
    my ($self, @args) = @_;

    return undef unless @args;

    my %rc = ( origin => '', decode => '' );
    foreach my $arg (@args) {
        next unless ref($arg);
        $rc{origin} .= $arg->{origin} // '';
        $rc{decode} .= $arg->{decode} // '';
    }
    \%rc
}
#
# Exactly the same as ESLIF's ::transfer built-in, but revisited
# to work on original and decoded strings at the same time
#
sub _symbol {
    my ($self, $symbol) = @_;
    { origin => $symbol, decode => $symbol }
}

#
# Just to avoid automatic generation of DESTROY() method by
# the AUTOLOAD just after -;
#
sub DESTROY {}
#
# Any other method is added on-the-fly
#
sub AUTOLOAD {
  my $field = $AUTOLOAD;
  $field =~ s/.*:://;

  fresh $field => sub {
      my ($self, @args) = @_;
      $self->{$field} = $self->_concat(@args)
  };
  goto &$field
}

1;
