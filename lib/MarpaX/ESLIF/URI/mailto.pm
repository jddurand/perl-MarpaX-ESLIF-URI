use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::mailto;

# ABSTRACT: URI::ftp syntax as per RFC1738

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

has '_address' => (is => 'rwp' );

#
# Inherited method
#
__PACKAGE__->_generate_actions(qw/_address/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::ftp inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

=head2 $class->bnf

Overwrites parent's bnf implementation. Returns the BNF used to parse the input.

=cut

sub bnf {
  my ($class) = @_;

  join("\n", $BNF, MarpaX::ESLIF::URI::_generic->bnf)
};

=head2 $class->grammar

Overwrite parent's grammar implementation. Returns the compiled BNF used to parse the input as MarpaX::ESLIF::Grammar singleton.

=cut

sub grammar {
  my ($class) = @_;

  return $GRAMMAR;
}

=head2 $self->address($type)

Returns the address, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut
    
sub address {
    my ($self, $type) = @_;

    return $self->_generic_getter('_address', $type)
}

# -------------
# Normalization
# -------------

=head1 SEE ALSO

L<RFC1738|https://tools.ietf.org/html/rfc1738>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc8089#section-2
#
<mailto URI>             ::= <mailto scheme> ":" <mailto hier part>                      action => _action_string # No query nor fragment

<mailto scheme>          ::= "mailto":i                                                  action => _action_scheme

<mailto hier part>       ::= <mailto address>

<mailto address>         ::= <mailto address value>                                      action => _action_address
<mailto address value>   ::= <mailto xchar>+


<mailto xchar>           ::= <unreserved> | <reserved> | <pct encoded>
#
# Generic syntax will be appended here
#
