use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::https;

# ABSTRACT: URI::https syntax as per RFC7230

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny::Antlers;
use Class::Method::Modifiers qw/around/;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::https inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

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

# -------------
# Normalization
# -------------
around _set__authority => sub {
    my ($orig, $self, $value) = @_;
    #
    # If the port is equal to the default port for a scheme, the normal
    # form is to omit the port subcomponent
    #
    my $port = $self->port;
    if (defined($port) && ($port == 80)) {
        my $new_port = $self->_port;
        $new_port->{normalized} = undef;
        $self->_set__port($new_port);
        $value->{normalized} =~ s/:[^:]+//
    }
    $self->$orig($value)
};

around _set__path => sub {
    my ($orig, $self, $value) = @_;
    #
    # Normalized path is '/' instead of empty, as if
    # it was a <path absolute>
    #
    if (! length($value->{normalized})) {
        $value->{normalized} = '/'
    }
    $self->$orig($value)
};

=head1 SEE ALSO

L<RFC7230|https://tools.ietf.org/html/rfc7230>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc7230#section-2.7.1
#
<https URI>             ::= <https scheme> ":" <https hier part> <URI query> <URI fragment> action => _action_string

<https scheme>          ::= "https":i                                                       action => _action_scheme
#
# Empty host is invalid
#
<https hier part> ::= "//" <https authority> <path abempty>

<https authority>       ::= <https authority value>                                         action => _action_authority
<https authority value> ::= <authority userinfo> <https host> <authority port>
<https host>            ::= <IP literal>            rank =>  0                              action => _action_host
                         | <IPv4address>           rank => -1                               action => _action_host
                         | <https reg name>         rank => -2                              action => _action_host

<https reg name>        ::= <reg name unit>+

#
# Generic syntax will be appended here
#
