use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Method::Modifiers qw/fresh around/;
use Class::Tiny::Antlers;
use Log::Any qw/$log/;
use MarpaX::ESLIF;
use MarpaX::ESLIF::URI::_generic::RecognizerInterface;
use MarpaX::ESLIF::URI::_generic::ValueInterface;
use Safe::Isa qw/$_isa/;
use overload '""' => 'string', 'cmp' => 'cmp', fallback => 1;

has '_origin'    => ( is => 'ro' );
has '_string'    => ( is => 'rwp' );
has '_scheme'    => ( is => 'rwp' );
has '_authority' => ( is => 'rwp' );
has '_userinfo'  => ( is => 'rwp' );
has '_host'      => ( is => 'rwp' );
has '_ip'        => ( is => 'rwp' );
has '_ipv4'      => ( is => 'rwp' );
has '_ipv6'      => ( is => 'rwp' );
has '_ipvx'      => ( is => 'rwp' );
has '_zone'      => ( is => 'rwp' );
has '_port'      => ( is => 'rwp' );
has '_path'      => ( is => 'rwp', default => sub { { origin => '', decode => '', canonical => '' } }); # Default is empty path ./..
has '_segments'  => ( is => 'rwp', default => sub { { origin => [], decode => [], canonical => [] } });  # ../. i.e. no component
has '_query'     => ( is => 'rwp' );
has '_fragment'  => ( is => 'rwp' );
has '_opaque'    => ( is => 'rwp' );

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

sub BUILD {
    my ($self) = @_;

    my $_origin = $self->_origin;
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

=head2 $self->string($type)

Returns the string version of the URI, C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub string {
    my ($self, $type) = @_;

    return $self->_generic_getter('_string', $type)
}

=head2 $self->scheme

Returns the scheme, or undef.

=cut
    
sub scheme {
    my ($self) = @_;
    #
    # scheme never have a percent encoded character
    #
    return $self->_generic_getter('_scheme')
}

=head2 $self->authority($type)

Returns the authority, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub authority {
    my ($self, $type) = @_;

    return $self->_generic_getter('_authority', $type)
}

=head2 $self->userinfo($type)

Returns the userinfo, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub userinfo {
    my ($self, $type) = @_;

    return $self->_generic_getter('_userinfo', $type)
}

=head2 $self->host

Returns the host (which may contain C<[]> delimiters in case of Ipv6 literal), or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub host {
    my ($self, $type) = @_;

    return $self->_generic_getter('_host', $type)
}

=head2 $self->ip

Returns the IP when host is such a literal, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub ip {
    my ($self) = @_;
    #
    # ip never have a percent encoded character
    #
    return $self->_generic_getter('_ip')
}

=head2 $self->ipv4

Returns the IPv4 when host is such a literal, or undef.

=cut
    
sub ipv4 {
    my ($self) = @_;
    #
    # ipv4 never have a percent encoded character
    #
    return $self->_generic_getter('_ipv4')
}

=head2 $self->ipv6

Returns the IPv6 when host is such a literal, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub ipv6 {
    my ($self) = @_;
    #
    # ipv6 never have a percent encoded character
    #
    return $self->_generic_getter('_ipv6')
}

=head2 $self->ipvx

Returns the decoded IPvI<future> (as per the spec) when host is such a literal, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub ipvx {
    my ($self) = @_;
    #
    # ipvx never have a percent encoded character
    #
    return $self->_generic_getter('_ipvx')
}

=head2 $self->zone

Returns the IPv6 Zone Id, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub zone {
    my ($self) = @_;
    #
    # zone never have a percent encoded character
    #
    return $self->_generic_getter('_zone')
}

=head2 $self->port

Returns the port, or undef.

=cut
    
sub port {
    my ($self) = @_;
    #
    # port never have a percent encoded character
    #
    return $self->_generic_getter('_port')
}

=head2 $self->path

Returns the path, or the empty string. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub path {
    my ($self, $type) = @_;

    return $self->_generic_getter('_path', $type)
}

=head2 $self->segments

Returns the path segments as an array reference, which may be empty. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub segments {
    my ($self, $type) = @_;

    return $self->_generic_getter('_segments', $type)
}

=head2 $self->query

Returns the query, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub query {
    my ($self, $type) = @_;

    return $self->_generic_getter('_query', $type)
}

=head2 $self->fragment

Returns the fragment, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub fragment {
    my ($self, $type) = @_;

    return $self->_generic_getter('_fragment', $type)
}

=head2 $self->opaque

Returns the part between scheme and fragment. C<$type> is either 'decoded' (default value), 'origin' or 'canonical'.

=cut
    
sub opaque {
    my ($self, $type) = @_;

    return $self->_generic_getter('_opaque', $type)
}

=head2 $self->is_abs

Returns a true value if the URI is absolute.

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
    return $self
  } else {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI without a scheme" unless defined $self->_scheme;
    my $_string = $self->_string->{origin};
    my $_fragment = $self->_fragment->{origin};
    my $quote__fragment = quotemeta($_fragment);
    $_string =~ s/#$quote__fragment$//;
    return ref($self)->new(_origin => $_string)
  }
}

=head2 $self->cmp($other)

Returns a instance that is the absolute version of current instance if possible, or croak on failure.

=cut

sub cmp {
    my ($self, $other, $swap) = @_;

    croak '$self must be an instance of ' . __PACKAGE__ unless $self->$_isa(__PACKAGE__);
    croak '$other must be an instance of ' . __PACKAGE__ unless $other->$_isa(__PACKAGE__);

    if ($swap) {
        my $tmp = $self;
        $self = $other;
        $other = $tmp
    }
    #
    # Since we already do full normalization when valuating the parse tree, we use it
    #
    return $self->string('canonical') cmp $other->string('canonical')
}

# ----------------
# Internal helpers
# ----------------

sub _generic_getter {
    my ($self, $_what, $type) = @_;

    $type //= 'decode';
    my $value = $self->$_what;

    return unless defined($value);
    return $value->{$type}
}

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
      \$self->_set_$attribute(\$self->__concat(\@args))
    }" || croak "Failed to create action stub for attribute $attribute, $@";
    fresh $method => $stub;
  }
}

# -------------
# Normalization
# -------------
around _set__scheme => sub {
    my ($orig, $self, $value) = @_;

    #
    # Canonical scheme is case insensitive
    #
    $value->{canonical} = lc($value->{canonical});
    $self->$orig($value)
};

around _set__host => sub {
    my ($orig, $self, $value) = @_;

    #
    # Canonical host is case insensitive
    #
    $value->{canonical} = lc($value->{canonical});
    $self->$orig($value)
};

around _set__path => sub {
    my ($orig, $self, $value) = @_;

    #
    # Canonical path is removing dot segments
    #
    $value->{canonical} = lc($value->{canonical});
    $self->$orig($value)
};

# ------------------------
# Grammar Internal helpers
# ------------------------
#
# This _pct_encoded method guarantees that the output is a sequence of ASCII characters
# even if the UTF-8 flag would be set. For instance sequence %ce%a3 will be
# seen as "\x{ce}\x{a3}" in the resulting string, and NOT "\x{cea3}".
#
sub __pct_encoded {
    my ($self, undef, $hex1, $hex2) = @_;
    #
    # Note that here $hex are terminals, so in fact hex's origin == decode == canonical
    #
    my $origin = join('', '%', $hex1->{origin}, $hex2->{origin});
    my $decode = chr(hex(join('', $hex1->{decode}, $hex2->{decode})));
    #
    # Normalization is decoding any percent-encoded octet that corresponds
    # to an unreserved character, as described in Section 2.3:
    # unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
    # 
    my $canonical = ($decode =~ /[A-Za-z0-9\-._~]/) ? $decode : $origin;
    return { origin => $origin, decode => $decode, canonical => $canonical }
}
#
# Special for zone
#
sub __percent_character {
    #
    # '%' decoded character is not an unreserved character, so the
    # canonicalized form remains %25
    #
    return { origin => '%25', decode => '%', canonical => '%25'}
}
#
# Pushes segments in a _segment[] array
#
sub __segment {
    my ($self, @args) = @_;

    my $concat = $self->__concat(@args);
    push(@{$self->_segments->{origin}},    $concat->{origin});
    push(@{$self->_segments->{decode}},    $concat->{decode});
    push(@{$self->_segments->{canonical}}, $concat->{canonical});
    return $concat
}
#
# Exactly the same as ESLIF's ::concat built-in, but revisited
# to work on original and decoded strings at the same time
#
sub __concat {
    my ($self, @args) = @_;

    my %rc = ( origin => '', decode => '', canonical => '' );
    foreach my $arg (@args) {
        next unless ref($arg);
        $rc{origin}    .= $arg->{origin} // '';
        $rc{decode}    .= $arg->{decode} // '';
        $rc{canonical} .= $arg->{canonical} // '';
      }
    return \%rc
}
#
# Exactly the same as ESLIF's ::transfer built-in, but revisited
# to work on original and decoded strings at the same time
#
sub __symbol {
    my ($self, $symbol) = @_;
    #
    # No normalization on symbol until we know the context
    #
    return { origin => $symbol, decode => $symbol, canonical => $symbol }
}

=head1 NOTES

=over

=item Logging

This package is L<Log::Any> aware, and will use the later in case parsing fails to output error messages.

=item Cloning

Please do C<MarpaX::ESLIF::URI->new($self)>.

=back

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
<IPv6addrz percent char> ::= "%25"                                                          action => __percent_character
<IPv6addrz>              ::= <IPv6address> <IPv6addrz percent char> <ZoneID>

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
