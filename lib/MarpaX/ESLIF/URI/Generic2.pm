use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic2;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny::Antlers qw/-all/;
use MarpaX::ESLIF;
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

  (@args == 1 && ! ref $args[0]) ? {string => $args[0]} : {@args}
  
};

sub BUILD {
    my ($self) = @_;
    if (! defined $self->path) {
        $self->_set_path('');
        $self->_set_segments([]);
        local $MarpaX::ESLIF::URI::Generic2::STRING = $self->string;
        $GRAMMAR->parse($self, $self) || croak 'Parse failure' # RecognizerInterface, $valueInterface
    }
}

sub stringify {
  my ($self) = @_;

  $self->string
}

sub clone {
  my ($self) = @_;

  my $class = ref($self);
  $class->new(map { $_ => $self->$_ } Class::Tiny->get_all_attributes_for($class))
}

sub is_abs {
    my ($self) = @_;

    defined($self->scheme) && ! defined($self->fragment)
}

sub abs {
  my ($self) = @_;

  my $clone = $self->clone;
  if (! $self->is_abs) {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI from $self: there is no scheme" unless defined $clone->scheme;
    #
    # Here per def there is a fragment, the base URI is the current URI without this fragment
    #
    my $string = $clone->string;
    my $quote_fragment = quotemeta($self->fragment);
    $string =~ s/#$quote_fragment$//;
    $clone->_set_string($string);
    $clone->_set_fragment(undef)
  }
  $clone
}

#
# Recognizer Interface required methods
#
sub read                   {             1 } # First read callback will be ok
sub isEof                  {             1 } # ../. and we will say this is EOF
sub isCharacterStream      {             1 } # MarpaX::ESLIF will validate the input
sub encoding               {               } # Let MarpaX::ESLIF guess
sub data                   { $MarpaX::ESLIF::URI::Generic2::STRING } # Input
sub isWithDisableThreshold {             0 } # Disable threshold warning ?
sub isWithExhaustion       {             0 } # Exhaustion event ?
sub isWithNewline          {             0 } # Newline count ?
sub isWithTrack            {             0 } # Absolute position tracking ?

#
# Value Interface required methods
#
sub isWithHighRankOnly { 1 }  # When there is the rank adverb: highest ranks only ?
sub isWithOrderByRank  { 1 }  # When there is the rank adverb: order by rank ?
sub isWithAmbiguous    { 0 }  # Allow ambiguous parse ?
sub isWithNull         { 0 }  # Allow null parse ?
sub maxParses          { 0 }  # Maximum number of parse tree values - meaningless when !isWithAmbiguous
sub setResult          { ''}  # No-op here
sub getResult          { ''}  # No-op here

# Specific value methods
sub _push_segment {
    my ($self, @args) = @_;

    my $segment = join('', map { $_ // '' } @args);
    push(@{$self->segments}, $segment);
    $segment
}

# Specific value methods. Default is to NOT decode.
sub _pct_encoded {
    my ($self, $pctcharacter, $hex1, $hex2) = @_;

    $MarpaX::ESLIF::URI::Generic2::DECODE ? chr(hex("$hex1$hex2")) : "$pctcharacter$hex1$hex2"
}

# Method modifiers
# Make sure path is never undef
around _set_path => sub {
    my ($orig, $self, $path) = @_;

    $self->$orig($path // '')
};

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

<scheme>                 ::= <scheme value>                                                 action => _set_scheme
<scheme value>           ::= <ALPHA> <scheme trailer>
<scheme trailer unit>    ::= <ALPHA> | <DIGIT> | "+" | "-" | "."
<scheme trailer>         ::= <scheme trailer unit>*

<authority userinfo>     ::= <userinfo> "@"
<authority userinfo>     ::=
<authority port>         ::= ":" <port>
<authority port>         ::=
<authority>              ::= <authority value>                                              action => _set_authority
<authority value>        ::= <authority userinfo> <host> <authority port>
<userinfo unit>          ::= <unreserved> | <pct encoded> | <sub delims> | ":"
<userinfo>               ::= <userinfo value>                                               action => _set_userinfo
<userinfo value>         ::= <userinfo unit>*
#
# The syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.
#
<host>                   ::= <IP literal>            rank =>  0                             action => _set_host
                           | <IPv4address>           rank => -1                             action => _set_host
                           | <reg name>              rank => -2                             action => _set_host
<port>                   ::= <port value>                                                   action => _set_port
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
<path abempty>           ::= <path abempty value>                                           action => _set_path
<path abempty value>     ::= <path abempty unit>*
<path absolute>          ::= <path absolute value>                                          action => _set_path
<path absolute value>    ::= "/"
                           | "/" <segment nz> <path abempty>
<path noscheme>          ::= <path noscheme value>                                          action => _set_path
<path noscheme value>    ::= <segment nz nc> <path abempty>
<path rootless>          ::= <path rootless value>                                          action => _set_path
<path rootless value>    ::= <segment nz> <path abempty>
<path empty>             ::=                                                                # Default value for path is ''

<segment>                ::= <pchar>*                                                       action => _push_segment
<segment nz>             ::= <pchar>+                                                       action => _push_segment
<segment nz nc unit>     ::= <unreserved> | <pct encoded> | <sub delims> | "@" # non-zero-length segment without any colon ":"
<segment nz nc>          ::= <segment nz nc unit>+                                          action => _push_segment

<pchar>                  ::= <unreserved> | <pct encoded> | <sub delims> | ":" | "@"

<query unit>             ::= <pchar> | "/" | "?"
<query>                  ::= <query value>                                                  action => _set_query
<query value>            ::= <query unit>*

<fragment unit>          ::= <pchar> | "/" | "?"
<fragment>               ::= <fragment value>                                               action => _set_fragment
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
