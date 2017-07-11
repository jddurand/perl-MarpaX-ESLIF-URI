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
    my ($pkg, %options) = @_;

    bless {
        result => undef,
        tmp => {
            scheme    => undef,
            authority => undef,
            path      => '',                # Path is never undef per def
            segments  => [],                # So are the segments
            query     => undef,
            fragment  => undef,
            userinfo  => undef,
            host      => undef,
            port      => undef
        },
        %options }, $pkg
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

sub scheme {
  my $self = shift;
  $self->{tmp}->{scheme} = join('', map { $_ // '' } @_ )
}

sub authority {
  my $self = shift;
  $self->{tmp}->{authority} = join('', map { $_ // '' } @_ )
}

sub path {
  my $self = shift;
  $self->{tmp}->{path} = join('', map { $_ // '' } @_ )
}

sub segment {
    my $self = shift;
    my $segment = join('', map { $_ // '' } @_ );
    push(@{$self->{tmp}->{segments}}, $segment);
    $segment
}

sub query {
  my $self = shift;
  $self->{tmp}->{query} = join('', map { $_ // '' } @_ )
}

sub fragment {
  my $self = shift;
  $self->{tmp}->{fragment} = join('', map { $_ // '' } @_ )
}

sub userinfo {
  my $self = shift;
  $self->{tmp}->{userinfo} = join('', map { $_ // '' } @_ )
}

sub host {
  my $self = shift;
  $self->{tmp}->{host} = $_[0]
}

sub port {
  my $self = shift;
  $self->{tmp}->{port} = join('', map { $_ // '' } @_ )
}

1;
