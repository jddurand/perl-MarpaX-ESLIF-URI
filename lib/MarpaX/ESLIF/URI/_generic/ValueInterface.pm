use strict;
use warnings FATAL => 'all';
#
# This package is built with performance in minde, so this is old-style
#
package MarpaX::ESLIF::URI::_generic::ValueInterface;

# VERSION

# AUTHORITY

# ABSTRACT: MarpaX::ESLIF's URI Value Interface

use Carp qw/croak/;
use vars qw/$AUTOLOAD/;
use Class::Method::Modifiers qw/fresh/;

sub new {
  my ($class, $action_provider) = @_;
  croak 'action_provider must be a reference' unless ref($action_provider);
  return bless \$action_provider, $class
}

sub DESTROY {
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

#
# Any necessary method is added on-the-fly, and this will croak if it is not provided -;
#
sub AUTOLOAD {
  my $method = $AUTOLOAD;
  $method =~ s/.*:://;
  #
  # We create it inlined with performance in mind
  #
  fresh $method => eval "sub {
    my (\$self, \@args) = \@_;
    return \$\$self->$method(\@args)
  }";
  goto &$method
}

1;
