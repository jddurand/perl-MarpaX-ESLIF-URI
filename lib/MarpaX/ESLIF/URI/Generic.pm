use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny::Antlers qw/-all/;
use MarpaX::ESLIF;
use MarpaX::ESLIF::URI::Generic::RecognizerInterface;
use MarpaX::ESLIF::URI::Generic::ValueInterface;
use overload '""' => 'stringify', fallback => 1;

has string     => (is => 'rwp');
has scheme     => (is => 'rwp');
has authority  => (is => 'rwp');
has userinfo   => (is => 'rwp');
has host       => (is => 'rwp');
has port       => (is => 'rwp');
has path       => (is => 'rwp');
has segments   => (is => 'rwp');
has query      => (is => 'rwp');
has fragment   => (is => 'rwp');

my $BNF = do { local $/; <DATA> };
my $ESLIF = MarpaX::ESLIF->new();
my $GRAMMAR = MarpaX::ESLIF::Grammar->new($ESLIF, $BNF);

sub BUILDARGS {
  my ($class, @args) = @_;

  croak "Usage: $class->new(\$uri)" unless (@args == 1 && ! ref $args[0]);
  $class->parse($args[0])
};

sub parse {
    my ($class, $uri) = @_;

    my $recognizerInterface = MarpaX::ESLIF::URI::Generic::RecognizerInterface->new($uri);
    my $valueInterface = MarpaX::ESLIF::URI::Generic::ValueInterface->new();

    $GRAMMAR->parse($recognizerInterface, $valueInterface) || croak 'Parse failure';
    $valueInterface->getResult || croak 'Parse value failure'
}

sub stringify {
  my ($self) = @_;

  my $string = '';

  my $scheme = $self->scheme;
  $string .= "$scheme:" if defined $scheme;
  
  my $authority = $self->authority;
  $string .= "//$authority" if defined $authority;
  
  $string .= $self->path;

  my $query = $self->query;
  $string .= "?$query" if defined $query;
  
  my $fragment = $self->fragment;
  $string .= "#$fragment" if defined $fragment;
  
  $string
}

sub clone {
  my ($self) = @_;

  __PACKAGE__->new("$self")
}

sub is_abs {
    my ($self) = @_;

    defined($self->scheme) && ! defined($self->fragment)
}

sub abs {
  my ($self) = @_;

  if ($self->is_abs) {
      $self->clone;
  } else {
      #
      # We need the scheme
      #
      croak "Cannot derive a base URI from $self: there is no scheme" unless defined $self->scheme;
      #
      # Here per def there is a fragment, the base URI is the current URI without this fragment
      #
      my $string = "$self";
      my $quote_fragment = quotemeta($self->fragment);
      $string =~ s/#$quote_fragment$//;

      __PACKAGE__->new($string)
  }
}

1;

__DATA__
:start ::= <URI reference>
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

<URI reference>          ::= <URI>
                           | <relative ref>

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

<IP literal interior>    ::= <IPv6address> | <IPv6addrz> | <IPvFuture>
<IP literal>             ::= "[" <IP literal interior> "]"
<ZoneID interior>        ::= <unreserved>  | <pct encoded>
<ZoneID>                 ::= <ZoneID interior>+
<IPv6addrz>              ::= <IPv6address> "%25" <ZoneID>

<IPvFuture>              ::= "v" <HEXDIG many> "." <IPvFuture trailer>
<IPvFuture trailer unit> ::= <unreserved> | <sub delims> | ":"
<IPvFuture trailer>      ::= <IPvFuture trailer unit>+

<IPv6address>            ::=                                   <6 h16 colon> <ls32>
                           |                              "::" <5 h16 colon> <ls32>
                           |                      <h16>   "::" <4 h16 colon> <ls32>
                           |                              "::" <4 h16 colon> <ls32>
                           |   <0 to 1 h16 colon> <h16>   "::" <3 h16 colon> <ls32>
                           |                              "::" <3 h16 colon> <ls32>
                           |   <0 to 2 h16 colon> <h16>   "::" <2 h16 colon> <ls32>
                           |                              "::" <2 h16 colon> <ls32>
                           |   <0 to 3 h16 colon> <h16>   "::" <1 h16 colon> <ls32>
                           |                              "::" <1 h16 colon> <ls32>
                           |   <0 to 4 h16 colon> <h16>   "::"               <ls32>
                           |                              "::"               <ls32>
                           |   <0 to 5 h16 colon> <h16>   "::"               <h16>
                           |                              "::"               <h16>
                           |   <0 to 6 h16 colon> <h16>   "::"
                           |                              "::"

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
<IPv4address>            ::= <dec octet> "." <dec octet> "." <dec octet> "." <dec octet>

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

<segment>                ::= <pchar>*                                                       action => segment
<segment nz>             ::= <pchar>+                                                       action => segment
<segment nz nc unit>     ::= <unreserved> | <pct encoded> | <sub delims> | "@" # non-zero-length segment without any colon ":"
<segment nz nc>          ::= <segment nz nc unit>+                                          action => segment

<pchar>                  ::= <unreserved> | <pct encoded> | <sub delims> | ":" | "@"

<query unit>             ::= <pchar> | "/" | "?"
<query>                  ::= <query value>                                                  action => query
<query value>            ::= <query unit>*

<fragment unit>          ::= <pchar> | "/" | "?"
<fragment>               ::= <fragment value>                                               action => fragment
<fragment value>         ::= <fragment unit>*

<pct encoded>            ::= "%" <HEXDIG> <HEXDIG>                                          action => pct_encoded

<unreserved>             ::= <ALPHA> | <DIGIT> | "-" | "." | "_" | "~"
<reserved>               ::= <gen delims> | <sub delims>
<gen delims>             ::= ":" | "/" | "?" | "#" | "[" | "]" | "@"
<sub delims>             ::= "!" | "$" | "&" | "'" | "(" | ")"
                           | "*" | "+" | "," | ";" | "="

<HEXDIG many>            ::= <HEXDIG>+
<ALPHA>                  ::= [A-Za-z]
<DIGIT>                  ::= [0-9]
<HEXDIG>                 ::= [0-9A-Fa-f]          # case insensitive
