use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Method::Modifiers qw/around/;
use Class::Tiny qw/scheme authority userinfo host ip ipv4 ipv6 ipvx zone port path segments query fragment/,
  {
   path => '',
   segments => sub { [] }
   };
use Log::Any qw/$log/;
use MarpaX::ESLIF;
use MarpaX::ESLIF::URI::_generic::RecognizerInterface;
use MarpaX::ESLIF::URI::_generic::ValueInterface;

#
# Constant
#
our $BNF = do { local $/; <DATA> };
#
# ESLIF singleton
#
my $ESLIF = MarpaX::ESLIF->new($log);
#
# Grammar singleton, built using class methods
#
my $GRAMMAR;

=head1 SUBROUTINES/METHODS

=head2 $class->new($uri)

Instantiate a new object, or croak on failure. Takes as parameter an URI that will be parsed. The object instance is noted C<$self> below.

=cut

sub BUILDARGS {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return $class->_parse($args[0])
  } else {
    croak "Usage: $class->new(\$uri)" unless $MarpaX::ESLIF::URI::_generic::CLONE;
    return {@args}
  }
}

=head2 $class->bnf

Returns the grammar used to parse a URI using the generic syntax.

=cut

sub bnf {
  my ($class) = @_;

  return $BNF
}

#
# Class::Tiny generated methods
#

=head2 $self->scheme

Returns the scheme, or undef.

=head2 $self->authority

Returns the decoded authority, or undef.

=head2 $self->userinfo

Returns the decoded userinfo, or undef.

=head2 $self->host

Returns the decoded host (which may contain C<[]> delimiters in case of Ipv6 literal), or undef.

=head2 $self->ip

Returns the decoded ip when host is an IP literal, or undef.

=head2 $self->ipv4

Returns the decoded IPv4 when host is an IP of such type, or undef.

=head2 $self->ipv6

Returns the decoded IPv6 when host is an IP of such type, or undef.

=head2 $self->ipvx

Returns the decoded IPvI<future> (as per the spec) when host is an IP of such type, or undef.

=head2 $self->zone

Returns the decoded IP Zone Id when host is an IPv6 literal, or undef.

=head2 $self->port

Returns the port, or undef.

=head2 $self->path

Returns the decoded path, or the empty string.

=head2 $self->segments

Returns the path segments as an array reference, which may be empty.

=head2 $self->query

Returns the decoded query, or undef.

=head2 $self->fragment

Returns the decoded fragment, or undef.

=cut

#
# Our additional methods
#

=head2 $self->clone

Returns an exact clone of current instance.

=cut

sub clone {
  my ($self) = @_;

  return $self->_clone
}

=head2 $self->is_abs

Returns a true value if the parsed URI is absolute, a false value otherwise.

=cut

sub is_abs {
  my ($self) = @_;

  return defined($self->scheme) && ! defined($self->fragment)
}

=head2 $self->base

Returns a instance that is the absolute version of current instance if possible, or croak on failure.

=cut

sub base {
  my ($self) = @_;

  if ($self->is_abs) {
    return $self->_clone
  } else {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI without a scheme" unless defined $self->scheme;
    return $self->_clone(fragment => undef)
  }
}

#
# Method modifiers: explicitely state the read-only mode on all methods
#
foreach my $method (Class::Tiny->get_all_attributes_for(__PACKAGE__)) {
  around $method => sub {
    my ($orig, $self, @args) = @_;
    my $class = ref($self);
    croak "$class::$method is read-only" if @args;
    return $self->$orig
  }
}

#
# Internals
#

sub _grammar {
  my ($class) = @_;

  return $GRAMMAR //= MarpaX::ESLIF::Grammar->new($ESLIF, $class->bnf)
}

sub _parse {
    my ($class, $uri) = @_;

    my $recognizerInterface = MarpaX::ESLIF::URI::_generic::RecognizerInterface->new($uri);
    my $valueInterface = MarpaX::ESLIF::URI::_generic::ValueInterface->new();

    $class->_grammar->parse($recognizerInterface, $valueInterface) || croak 'Parse failure';
    return $valueInterface->getResult || croak 'Parse value failure'
}

sub _clone {
  my ($self, %forced) = @_;

  local $MarpaX::ESLIF::URI::_generic::CLONE = 1;
  my $class = ref($self);
  return $class->new(
                     (
                      map {
                        $_ => exists($forced{$_}) ? $forced{$_} : $self->$_
                      } Class::Tiny->get_all_attributes_for($class)
                     )
                    )
}

=head1 NOTES

This package is L<Log::Any> aware, and will use the later in case parsing fails to output error messages.

=head1 SEE ALSO

L<MarpaX::ESLIF::URI>, L<RFC3986|https://tools.ietf.org/html/rfc3986>, L<RFC6874|https://tools.ietf.org/html/rfc6874>

=cut

1;

__DATA__
# :start ::= <URI reference>
<URI reference>          ::= <URI>
                           | <relative ref>
#
# Reference: https://tools.ietf.org/html/rfc3986#appendix-A
# Reference: https://tools.ietf.org/html/rfc6874
#
<URI>                    ::= <scheme> ":" <hier part> <URI query> <URI fragment>
<URI query>              ::= "?" <query>
<URI query>              ::=
<URI fragment>           ::= "#" <fragment>
<URI fragment>           ::=

<hier part>              ::= "//" <authority> <path abempty>
                           | <path absolute>
                           | <path rootless>
                           | <path empty>


<absolute URI>           ::= <scheme> ":" <hier part> <URI query>

<relative ref>           ::= <relative part> <URI query> <URI fragment>

<relative part>          ::= "//" <authority> <path abempty>
                           | <path absolute>
                           | <path noscheme>
                           | <path empty>

<scheme>                 ::= <scheme value>                                                 action => scheme
<scheme value>           ::= <ALPHA> <scheme trailer>
<scheme trailer unit>    ::= <ALPHA> | <DIGIT> | "+" | "-" | "."
<scheme trailer>         ::= <scheme trailer unit>*

<authority userinfo>     ::= <userinfo> "@"
<authority userinfo>     ::=
<authority port>         ::= ":" <port>
<authority port>         ::=
<authority>              ::= <authority value>                                              action => authority
<authority value>        ::= <authority userinfo> <host> <authority port>
<userinfo unit>          ::= <unreserved> | <pct encoded> | <sub delims> | ":"
<userinfo>               ::= <userinfo value>                                               action => userinfo
<userinfo value>         ::= <userinfo unit>*
#
# The syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.
#
<host>                   ::= <IP literal>            rank =>  0                             action => host
                           | <IPv4address>           rank => -1                             action => host
                           | <reg name>              rank => -2                             action => host
<port>                   ::= <port value>                                                   action => port
<port value>             ::= <DIGIT>*

<IP literal interior>    ::= <IPv6address>                                                  action => ip
                           | <IPv6addrz>                                                    action => ip
                           | <IPvFuture>                                                    action => ip
<IP literal>             ::= "[" <IP literal interior> "]"
<ZoneID interior>        ::= <unreserved>  | <pct encoded>
<ZoneID>                 ::= <ZoneID interior>+                                             action => zone
<IPv6addrz>              ::= <IPv6address> "%25" <ZoneID>

<IPvFuture>              ::= "v" <HEXDIG many> "." <IPvFuture trailer>                      action => ipvx
<IPvFuture trailer unit> ::= <unreserved> | <sub delims> | ":"
<IPvFuture trailer>      ::= <IPvFuture trailer unit>+

<IPv6address>            ::=                                   <6 h16 colon> <ls32>         action => ipv6
                           |                              "::" <5 h16 colon> <ls32>         action => ipv6
                           |                      <h16>   "::" <4 h16 colon> <ls32>         action => ipv6
                           |                              "::" <4 h16 colon> <ls32>         action => ipv6
                           |   <0 to 1 h16 colon> <h16>   "::" <3 h16 colon> <ls32>         action => ipv6
                           |                              "::" <3 h16 colon> <ls32>         action => ipv6
                           |   <0 to 2 h16 colon> <h16>   "::" <2 h16 colon> <ls32>         action => ipv6
                           |                              "::" <2 h16 colon> <ls32>         action => ipv6
                           |   <0 to 3 h16 colon> <h16>   "::" <1 h16 colon> <ls32>         action => ipv6
                           |                              "::" <1 h16 colon> <ls32>         action => ipv6
                           |   <0 to 4 h16 colon> <h16>   "::"               <ls32>         action => ipv6
                           |                              "::"               <ls32>         action => ipv6
                           |   <0 to 5 h16 colon> <h16>   "::"               <h16>          action => ipv6
                           |                              "::"               <h16>          action => ipv6
                           |   <0 to 6 h16 colon> <h16>   "::"                              action => ipv6
                           |                              "::"                              action => ipv6

<1 h16 colon>            ::= <h16> ":"
<2 h16 colon>            ::= <h16> ":" <h16> ":"
<3 h16 colon>            ::= <h16> ":" <h16> ":" <h16> ":"
<4 h16 colon>            ::= <h16> ":" <h16> ":" <h16> ":" <h16> ":"
<5 h16 colon>            ::= <h16> ":" <h16> ":" <h16> ":" <h16> ":" <h16> ":"
<6 h16 colon>            ::= <h16> ":" <h16> ":" <h16> ":" <h16> ":" <h16> ":" <h16> ":"

#
# These productions are ambiguous without ranking (rank is equivalent to make regexps greedy)
#
<0 to 1 h16 colon>       ::=
<0 to 1 h16 colon>       ::= <1 h16 colon>                    rank => 1
<0 to 2 h16 colon>       ::= <0 to 1 h16 colon>
<0 to 2 h16 colon>       ::= <0 to 1 h16 colon> <1 h16 colon> rank => 1
<0 to 3 h16 colon>       ::= <0 to 2 h16 colon>
<0 to 3 h16 colon>       ::= <0 to 2 h16 colon> <1 h16 colon> rank => 1
<0 to 4 h16 colon>       ::= <0 to 3 h16 colon>
<0 to 4 h16 colon>       ::= <0 to 3 h16 colon> <1 h16 colon> rank => 1
<0 to 5 h16 colon>       ::= <0 to 4 h16 colon>
<0 to 5 h16 colon>       ::= <0 to 4 h16 colon> <1 h16 colon> rank => 1
<0 to 6 h16 colon>       ::= <0 to 5 h16 colon>
<0 to 6 h16 colon>       ::= <0 to 5 h16 colon> <1 h16 colon> rank => 1

<h16>                    ::= <HEXDIG>
                           | <HEXDIG> <HEXDIG>
                           | <HEXDIG> <HEXDIG> <HEXDIG>
                           | <HEXDIG> <HEXDIG> <HEXDIG> <HEXDIG>

<ls32>                   ::= <h16> ":" <h16> | <IPv4address>
<IPv4address>            ::= <dec octet> "." <dec octet> "." <dec octet> "." <dec octet> action => ipv4

<dec octet>              ::= <DIGIT>                     # 0-9
                           | [\x{31}-\x{39}] <DIGIT>     # 10-99
                           | "1" <DIGIT> <DIGIT>         # 100-199
                           | "2" [\x{30}-\x{34}] <DIGIT> # 200-249
                           | "25" [\x{30}-\x{35}]        # 250-255

<reg name unit>          ::= <unreserved> | <pct encoded> | <sub delims>
<reg name>               ::= <reg name unit>*

<path>                   ::= <path abempty>                                                 # begins with "/" or is empty
                           | <path absolute>                                                # begins with "/" but not "//"
                           | <path noscheme>                                                # begins with a non-colon segment
                           | <path rootless>                                                # begins with a segment
                           | <path empty>                                                   # zero characters

<path abempty unit>      ::= "/" <segment>
<path abempty>           ::= <path abempty value>                                           action => path
<path abempty value>     ::= <path abempty unit>*
<path absolute>          ::= <path absolute value>                                          action => path
<path absolute value>    ::= "/"
                           | "/" <segment nz> <path abempty>
<path noscheme>          ::= <path noscheme value>                                          action => path
<path noscheme value>    ::= <segment nz nc> <path abempty>
<path rootless>          ::= <path rootless value>                                          action => path
<path rootless value>    ::= <segment nz> <path abempty>
<path empty>             ::=                                                                # Default value for path is ''

<segment>                ::= <pchar>*                                                       action => _segment
<segment nz>             ::= <pchar>+                                                       action => _segment
<segment nz nc unit>     ::= <unreserved> | <pct encoded> | <sub delims> | "@" # non-zero-length segment without any colon ":"
<segment nz nc>          ::= <segment nz nc unit>+                                          action => _segment

<pchar>                  ::= <unreserved> | <pct encoded> | <sub delims> | ":" | "@"

<query unit>             ::= <pchar> | "/" | "?"
<query>                  ::= <query value>                                                  action => query
<query value>            ::= <query unit>*

<fragment unit>          ::= <pchar> | "/" | "?"
<fragment>               ::= <fragment value>                                               action => fragment
<fragment value>         ::= <fragment unit>*

<pct encoded>            ::= "%" <HEXDIG> <HEXDIG>                                          action => _pct_encoded

<unreserved>             ::= <ALPHA> | <DIGIT> | "-" | "." | "_" | "~"
<reserved>               ::= <gen delims> | <sub delims>
<gen delims>             ::= ":" | "/" | "?" | "#" | "[" | "]" | "@"
<sub delims>             ::= "!" | "$" | "&" | "'" | "(" | ")"
                           | "*" | "+" | "," | ";" | "="

<HEXDIG many>            ::= <HEXDIG>+
<ALPHA>                  ::= [A-Za-z]
<DIGIT>                  ::= [0-9]
<HEXDIG>                 ::= [0-9A-Fa-f]          # case insensitive
