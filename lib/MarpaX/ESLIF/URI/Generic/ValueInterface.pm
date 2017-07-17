use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic::ValueInterface;

sub new {
    my ($class, %options) = @_;

    bless {
        decode    => $options{decode},
        result    => {
            scheme    => undef,
            authority => undef,
            userinfo  => undef,
            host      => undef,
            port      => undef,
            path      => '',
            segments  => [],
            query     => undef,
            fragment => undef
        }
    }, $class
}

#
# Value Interface required methods
#
sub isWithHighRankOnly {               1 } # When there is the rank adverb: highest ranks only ?
sub isWithOrderByRank  {               1 } # When there is the rank adverb: order by rank ?
sub isWithAmbiguous    {               0 } # Allow ambiguous parse ?
sub isWithNull         {               0 } # Allow null parse ?
sub maxParses          {               0 } # Maximum number of parse tree values - meaningless when !isWithAmbiguous
sub setResult          {                 } # No-op here
sub getResult          { $_[0]->{result} } # Result is the instance itself

#
# Grammar specific actions
#
sub segment {
    my ($self, @args) = @_;

    my $rc = join('', map { $_ // '' } @args);
    push(@{$self->{result}->{segments}}, $rc);
    $rc
}

# Specific value methods. Default is to NOT decode.
sub pct_encoded {
    my ($self, $pctcharacter, $hex1, $hex2) = @_;

    $MarpaX::ESLIF::URI::Generic2::DECODE ? chr(hex("$hex1$hex2")) : "$pctcharacter$hex1$hex2"
}

sub _generic {
    my ($self, $what, @args) = @_;

    $self->{result}->{$what} = join('', map { $_ // '' } @args)
}

sub scheme    { shift->_generic('scheme',    @_) }
sub authority { shift->_generic('authority', @_) }
sub userinfo  { shift->_generic('userinfo',  @_) }
sub host      { shift->_generic('host',      @_) }
sub port      { shift->_generic('port',      @_) }
sub path      { shift->_generic('path',      @_) }
sub query     { shift->_generic('query',     @_) }
sub fragment  { shift->_generic('fragment',  @_) }

1;
