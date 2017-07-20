use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::file;

# ABSTRACT: URI::file syntax as per RFC8089

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

has '_drive' => (is => 'rw' );

#
# Inherited method
#
__PACKAGE__->_generate_actions(qw/_drive/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::file inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

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

#
# Class::Tiny generated methods
#

=head2 $self->drive

Returns the drive letter, or undef.

=head1 SEE ALSO

L<RFC8089|https://tools.ietf.org/html/rfc8089>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc8089#section-2
#
<file URI>       ::= <file scheme> ":" <file hier part>            action => _action_string

<file scheme>    ::= "file":i                                      action => _action_scheme

<file hier part> ::= "//" <auth path>
                   | <local path>

#
# <auth path> is generating ambiguity
#
<auth path>      ::= <file auth> <path absolute>
                   |             <path absolute>
                   | <file auth> <file absolute> rank => 1
                   |             <file absolute> rank => 1
                   | <unc authority> <path absolute>

<local path>     ::= <drive letter> <path absolute>
                   |                <path absolute>
                   |                <file absolute>

<unc authority>  ::= "//" <file host>                              action => _action_authority
                   | "///" <file host>                             action => _action_authority

<file host>      ::= <inline IP>                                   action => _action_host
                   | IPv4address                                   action => _action_host
                   | <reg name>                                    action => _action_host

<inline IP>      ::= "%5B" <IPv6address> "%5D"
                   | "%5B" <IPvFuture> "%5D"

<file absolute>  ::= "/" <drive letter> <path absolute>

<drive>          ::= ALPHA                                         action => _action_drive

<drive letter>   ::= <drive> ":"
                   | <drive> "|"

<file auth>      ::= <userinfo> "@" <host>                         action => _action_authority
                   |                <host>                         action => _action_authority

<host>           ::= "localhost"                                   action => _action_host
#
# Generic syntax will be appended here
#
