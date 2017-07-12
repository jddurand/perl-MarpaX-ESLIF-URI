use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Grammar::ValueInterface;

# ABSTRACT: MarpaX::ESLIF::URI::Grammar Value Interface

# VERSION

# AUTHORITY

# -----------
# Constructor
# -----------

=head1 SUBROUTINES/METHODS

=head2 new($class)

Instantiate a new value interface object.

=cut

sub new {
    my ($pkg, $normalize) = @_;

    bless {
           result => undef,
           normalize => $normalize,
           tmp => {
                   URI_reference  => undef,
                   scheme         => undef,
                   authority      => undef,
                   userinfo       => undef,
                   host           => undef,
                   port           => undef,
                   path           => '',
                   segments       => [],
                   query          => undef,
                   fragment       => undef
                  },
           }, $pkg
}

# ----------------
# Required methods
# ----------------

=head2 Required methods

=head3 isWithHighRankOnly

Returns a true or a false value, indicating if valuation should use highest ranked rules or not, respectively. Default is a true value.

=cut

sub isWithHighRankOnly { 1 }  # When there is the rank adverb: highest ranks only ?

=head3 isWithOrderByRank

Returns a true or a false value, indicating if valuation should order by rule rank or not, respectively. Default is a true value.

=cut

sub isWithOrderByRank  { 1 }  # When there is the rank adverb: order by rank ?

=head3 isWithAmbiguous

Returns a true or a false value, indicating if valuation should allow ambiguous parse tree or not, respectively. Default is a false value.

=cut

sub isWithAmbiguous    { 0 }  # Allow ambiguous parse ?

=head3 isWithNull

Returns a true or a false value, indicating if valuation should allow a null parse tree or not, respectively. Default is a false value.

=cut

sub isWithNull         { 0 }  # Allow null parse ?

=head3 maxParses

Returns the number of maximum parse tree valuations. Default is unlimited (i.e. a false value).

=cut

sub maxParses          { 0 }  # Maximum number of parse tree values

=head3 getResult

Returns the current parse tree value.

=cut

sub getResult { $_[0]->{result} }

=head3 setResult

Sets the current parse tree value.

=cut

sub setResult { $_[0]->{result} = $_[0]->{tmp} }

=head1 SEE ALSO

L<MarpaX::ESLIF::RFC3986>

=cut

#
# Grammar actions
# ---------------
#
# ... Special actions so that setResult gets $self->{work}
#

sub _concat {
  my ($self, $what, @args) = @_;
  $self->{tmp}->{$what} = join('', map { $_ // '' } @args )
}

sub scheme        { shift->_concat('scheme',        @_) }
sub authority     { shift->_concat('authority',     @_) }
sub path          { shift->_concat('path',          @_) }
sub query         { shift->_concat('query',         @_) }
sub fragment      { shift->_concat('fragment',      @_) }
sub userinfo      { shift->_concat('userinfo',      @_) }
sub host          { shift->_concat('host',          @_) }
sub port          { shift->_concat('port',          @_) }
sub URI_reference { shift->_concat('URI_reference', @_) }

#
# Segment is a special action
#
sub segment {
    my $self = shift;
    my $segment = join('', map { $_ // '' } @_ );
    push(@{$self->{tmp}->{segments}}, $segment);
    $segment
}

#
# pct_encoded is a special action
#
sub pct_encoded {
    my ($self, $pct, $hex1, $hex2) = @_;

    if ($self->{normalize}) {
      #
      # Case normalization
      #
      $hex1 = uc($hex1);
      $hex2 = uc($hex2)
    }
    chr(hex("$hex1$hex2"))
}

1;
