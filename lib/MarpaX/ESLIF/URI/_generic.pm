use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Method::Modifiers qw/fresh/;
use Class::Tiny::Antlers;
use Log::Any qw/$log/;
use MarpaX::ESLIF;
use MarpaX::ESLIF::URI::_generic::RecognizerInterface;
use MarpaX::ESLIF::URI::_generic::ValueInterface;
use overload '""' => 'as_string', fallback => 1;

has '_origin'    => ( is => 'ro' );
has '_string'    => ( is => 'rw' );
has '_scheme'    => ( is => 'rw' );
has '_authority' => ( is => 'rw' );
has '_userinfo'  => ( is => 'rw' );
has '_host'      => ( is => 'rw' );
has '_ip'        => ( is => 'rw' );
has '_ipv4'      => ( is => 'rw' );
has '_ipv6'      => ( is => 'rw' );
has '_ipvx'      => ( is => 'rw' );
has '_zone'      => ( is => 'rw' );
has '_port'      => ( is => 'rw' );
has '_path'      => ( is => 'rw', default => sub { { origin => '', decode => '' } }); # Default is empty path ./..
has '_segments'  => ( is => 'rw', default => sub { { origin => [], decode => [] } });  # ../. i.e. no component
has '_query'     => ( is => 'rw' );
has '_fragment'  => ( is => 'rw' );
has '_opaque'    => ( is => 'rw' );

#
# All attributes starting with an underscore are the result of parsing
#
__PACKAGE__->_generate_actions(qw/_string _scheme _authority _userinfo _host _ip _ipv4 _ipv6 _ipvx _zone _port _path _segments _query _fragment _opaque/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $ESLIF = MarpaX::ESLIF->new($log);
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

=head2 $class->new($uri)

Instantiate a new object, or croak on failure. Takes as parameter an URI that will be parsed. The object instance is noted C<$self> below.

=cut

sub BUILDARGS {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return { _origin => $args[0] }
  } else {
    return {@args}
  }
}

sub BUILD {
    my ($self) = @_;

    my $_origin = $self->_origin;
    return unless defined($_origin);
    $_origin = "$_origin";
    if (length($_origin)) {
        my $recognizerInterface = MarpaX::ESLIF::URI::_generic::RecognizerInterface->new($_origin);
        my $valueInterface = MarpaX::ESLIF::URI::_generic::ValueInterface->new($self);

        $self->grammar->parse($recognizerInterface, $valueInterface) || croak 'Parse failure'
    }
}

=head2 $class->bnf

Returns the BNF used to parse the input.

=cut

sub bnf {
  my ($class) = @_;

  return $BNF
}

=head2 $class->eslif

Returns a MarpaX::ESLIF singleton.

=cut

sub eslif {
  my ($class) = @_;

  return $ESLIF
}

=head2 $class->grammar

Returns the compiled BNF used to parse the input as MarpaX::ESLIF::Grammar singleton.

=cut

sub grammar {
  my ($class) = @_;

  return $GRAMMAR;
}

#
# Class::Tiny generated methods
#

=head2 $self->string

Returns the unescaped string version of the URI.

=cut
    
sub string {
    my ($self, $type) = @_;

    $type //= 'decode';
    my $_string = $self->_string;

    return unless defined($_string);
    return $_string->{$type}
}

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

=head2 $self->opaque

Returns the part between scheme and fragment.

=cut

#
# Our additional methods
#

=head2 $self->clone

Returns an exact clone of current instance.

=cut

sub clone {
  my ($self) = @_;

  ref($self)->new($self->_origin)
}

=head2 $self->has_recognized_scheme

Returns a true value if the scheme is recognized.

=cut

sub has_recognized_scheme {
  my ($self) = @_;

  return defined($self->_scheme)
}

=head2 $self->as_string

Returns the unescaped string of the URI, which is always a valid Perl-extended UTF-8 string. This is also what prints out the stringification of C<$self>.

=cut

sub as_string {
  my ($self) = @_;

  return $self->string('decode')
}

=head2 $self->is_abs

Returns a true value if the parsed URI is absolute, a false value otherwise.

=cut

sub is_abs {
  my ($self) = @_;

  return defined($self->_scheme)
}

=head2 $self->base

Returns a instance that is the absolute version of current instance if possible, or croak on failure.

=cut

sub base {
  my ($self) = @_;

  if ($self->is_abs) {
    return $self
  } else {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI without a scheme" unless defined $self->_scheme;
    my $_string = $self->_string->{origin};
    my $_fragment = $self->_fragment->{origin};
    my $quote__fragment = quotemeta($_fragment);
    $_string =~ s/$quote__fragment$//;
    return ref($self)->new($_string)
  }
}

#
# Internals
#

sub _generate_actions {
  my ($class, @attributes) = @_;
  #
  # All the attributes have an associate explicit action called _action_$aattribute
  #
  foreach my $attribute (@attributes) {
    my $method = "_action$attribute";
    next if $class->can($method);
    my $stub = eval "sub {
      my (\$self, \@args) = \@_;
      \$self->$attribute(\$self->__concat(\@args))
    }" || croak "Failed to create action stub for attribute $attribute, $@";
    fresh $method => $stub;
  }
}

#
# This _pct_encoded method guarantees that the output is a sequence of ASCII characters
# even if the UTF-8 flag would be set. For instance sequence %ce%a3 will be
# seen as "\x{ce}\x{a3}" in the resulting string, and NOT "\x{cea3}".
#
sub __pct_encoded {
    my ($self, undef, $hex1, $hex2) = @_;

    return { origin => join('', '%', $hex1->{origin}, $hex2->{origin}), decode => chr(hex(join('', $hex1->{decode}, $hex2->{decode}))) }
}
#
# Pushes segments in a _segment[] array
#
sub __segment {
    my ($self, @args) = @_;

    my $concat = $self->__concat(@args);
    push(@{$self->_segments->{origin}}, $concat->{origin});
    push(@{$self->_segments->{decode}}, $concat->{decode});
    return $concat
}
#
# Exactly the same as ESLIF's ::concat built-in, but revisited
# to work on original and decoded strings at the same time
#
sub __concat {
    my ($self, @args) = @_;

    return undef unless @args;

    my %rc = ( origin => '', decode => '' );
    foreach my $arg (@args) {
        next unless ref($arg);
        $rc{origin} .= $arg->{origin} // '';
        $rc{decode} .= $arg->{decode} // '';
      }
    return \%rc
}
#
# Exactly the same as ESLIF's ::transfer built-in, but revisited
# to work on original and decoded strings at the same time
#
sub __symbol {
    my ($self, $symbol) = @_;
    return { origin => $symbol, decode => $symbol }
}

=head1 NOTES

This package is L<Log::Any> aware, and will use the later in case parsing fails to output error messages.

=head1 SEE ALSO

L<MarpaX::ESLIF::URI>, L<RFC3986|https://tools.ietf.org/html/rfc3986>, L<RFC6874|https://tools.ietf.org/html/rfc6874>

=cut

1;

__DATA__
#
# We maintain two string version in parallel when valuating the parse tree:
# - original
# - decoded
:default ::= action        => __concat
             symbol-action => __symbol

# :start ::= <URI reference>
<URI reference>          ::= <URI>                                                          action => _action_string
                           | <relative ref>                                                 action => _action_string
#
# Reference: https://tools.ietf.org/html/rfc3986#appendix-A
# Reference: https://tools.ietf.org/html/rfc6874
#
<URI opaque>             ::= <hier part> <URI query>                                        action => _action_opaque
<URI>                    ::= <scheme> ":" <URI opaque> <URI fragment>
<URI query>              ::= "?" <query>
<URI query>              ::=
<URI fragment>           ::= "#" <fragment>
<URI fragment>           ::=

<hier part>              ::= "//" <authority> <path abempty>
                           | <path absolute>
                           | <path rootless>
                           | <path empty>


<absolute URI>           ::= <scheme> ":" <hier part> <URI query>

<relative ref opaque>    ::= <relative part> <URI query>                                    action => _action_opaque
<relative ref>           ::= <relative ref opaque> <URI fragment>

<relative part>          ::= "//" <authority> <path abempty>
                           | <path absolute>
                           | <path noscheme>
                           | <path empty>

<scheme>                 ::= <scheme value>                                                 action => _action_scheme
<scheme value>           ::= <ALPHA> <scheme trailer>
<scheme trailer unit>    ::= <ALPHA> | <DIGIT> | "+" | "-" | "."
<scheme trailer>         ::= <scheme trailer unit>*

<authority userinfo>     ::= <userinfo> "@"
<authority userinfo>     ::=
<authority port>         ::= ":" <port>
<authority port>         ::=
<authority>              ::= <authority value>                                              action => _action_authority
<authority value>        ::= <authority userinfo> <host> <authority port>
<userinfo unit>          ::= <unreserved> | <pct encoded> | <sub delims> | ":"
<userinfo>               ::= <userinfo value>                                               action => _action_userinfo
<userinfo value>         ::= <userinfo unit>*
#
# The syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.
#
<host>                   ::= <IP literal>            rank =>  0                             action => _action_host
                           | <IPv4address>           rank => -1                             action => _action_host
                           | <reg name>              rank => -2                             action => _action_host
<port>                   ::= <port value>                                                   action => _action_port
<port value>             ::= <DIGIT>*

<IP literal interior>    ::= <IPv6address>                                                  action => _action_ip
                           | <IPv6addrz>                                                    action => _action_ip
                           | <IPvFuture>                                                    action => _action_ip
<IP literal>             ::= "[" <IP literal interior> "]"
<ZoneID interior>        ::= <unreserved>  | <pct encoded>
<ZoneID>                 ::= <ZoneID interior>+                                             action => _action_zone
<IPv6addrz>              ::= <IPv6address> "%25" <ZoneID>

<IPvFuture>              ::= "v" <HEXDIG many> "." <IPvFuture trailer>                      action => _action_ipvx
<IPvFuture trailer unit> ::= <unreserved> | <sub delims> | ":"
<IPvFuture trailer>      ::= <IPvFuture trailer unit>+

<IPv6address>            ::=                                   <6 h16 colon> <ls32>         action => _action_ipv6
                           |                              "::" <5 h16 colon> <ls32>         action => _action_ipv6
                           |                      <h16>   "::" <4 h16 colon> <ls32>         action => _action_ipv6
                           |                              "::" <4 h16 colon> <ls32>         action => _action_ipv6
                           |   <0 to 1 h16 colon> <h16>   "::" <3 h16 colon> <ls32>         action => _action_ipv6
                           |                              "::" <3 h16 colon> <ls32>         action => _action_ipv6
                           |   <0 to 2 h16 colon> <h16>   "::" <2 h16 colon> <ls32>         action => _action_ipv6
                           |                              "::" <2 h16 colon> <ls32>         action => _action_ipv6
                           |   <0 to 3 h16 colon> <h16>   "::" <1 h16 colon> <ls32>         action => _action_ipv6
                           |                              "::" <1 h16 colon> <ls32>         action => _action_ipv6
                           |   <0 to 4 h16 colon> <h16>   "::"               <ls32>         action => _action_ipv6
                           |                              "::"               <ls32>         action => _action_ipv6
                           |   <0 to 5 h16 colon> <h16>   "::"               <h16>          action => _action_ipv6
                           |                              "::"               <h16>          action => _action_ipv6
                           |   <0 to 6 h16 colon> <h16>   "::"                              action => _action_ipv6
                           |                              "::"                              action => _action_ipv6

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
<IPv4address>            ::= <dec octet> "." <dec octet> "." <dec octet> "." <dec octet> action => _action_ipv4

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
<path abempty>           ::= <path abempty value>                                           action => _action_path
<path abempty value>     ::= <path abempty unit>*
<path absolute>          ::= <path absolute value>                                          action => _action_path
<path absolute value>    ::= "/"
                           | "/" <segment nz> <path abempty>
<path noscheme>          ::= <path noscheme value>                                          action => _action_path
<path noscheme value>    ::= <segment nz nc> <path abempty>
<path rootless>          ::= <path rootless value>                                          action => _action_path
<path rootless value>    ::= <segment nz> <path abempty>
<path empty>             ::=                                                                # Default value for path is ''

<segment>                ::= <pchar>*                                                       action => __segment
<segment nz>             ::= <pchar>+                                                       action => __segment
<segment nz nc unit>     ::= <unreserved> | <pct encoded> | <sub delims> | "@" # non-zero-length segment without any colon ":"
<segment nz nc>          ::= <segment nz nc unit>+                                          action => __segment

<pchar>                  ::= <unreserved> | <pct encoded> | <sub delims> | ":" | "@"

<query unit>             ::= <pchar> | "/" | "?"
<query>                  ::= <query value>                                                  action => _action_query
<query value>            ::= <query unit>*

<fragment unit>          ::= <pchar> | "/" | "?"
<fragment>               ::= <fragment value>                                               action => _action_fragment
<fragment value>         ::= <fragment unit>*

<pct encoded>            ::= "%" <HEXDIG> <HEXDIG>                                          action => __pct_encoded

<unreserved>             ::= <ALPHA> | <DIGIT> | "-" | "." | "_" | "~"
<reserved>               ::= <gen delims> | <sub delims>
<gen delims>             ::= ":" | "/" | "?" | "#" | "[" | "]" | "@"
<sub delims>             ::= "!" | "$" | "&" | "'" | "(" | ")"
                           | "*" | "+" | "," | ";" | "="

<HEXDIG many>            ::= <HEXDIG>+
<ALPHA>                  ::= [A-Za-z]
<DIGIT>                  ::= [0-9]
<HEXDIG>                 ::= [0-9A-Fa-f]          # case insensitive
