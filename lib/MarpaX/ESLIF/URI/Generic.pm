use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny qw/input
                   scheme
                   authority
                   path
                   segments
                   query
                   fragment
                  /;
use MarpaX::ESLIF;
use MarpaX::ESLIF::URI::Generic::RecognizerInterface;
use MarpaX::ESLIF::URI::Generic::ValueInterface;
use Scalar::Util qw/blessed/;
use overload '""' => 'stringify', fallback => 1;

my $_BNF = do { local $/; <DATA> };
my $_ESLIF = MarpaX::ESLIF->new();
my $_GRAMMAR = MarpaX::ESLIF::Grammar->new($_ESLIF, $_BNF);

sub BUILDARGS {
  my ($class, @args) = @_;

  croak "Usage: " . __PACKAGE__ . "->new(\$input)" unless (@args == 1 && ! ref $args[0]);
  { input => $args[0] }
};

sub reconstruct {
  my ($self, %from) = @_;

  my $string;

  my $scheme = exists($from{scheme}) ? $from{scheme} : $self->scheme;
  $string .= "$scheme:" if defined($scheme);

  my $authority = exists($from{authority}) ? $from{authority} : $self->authority;
  $string .= "//$authority" if defined($authority);

  $string .= exists($from{path}) ? $from{path} : $self->path;

  my $query = exists($from{query}) ? $from{query} : $self->query;
  $string .= "?$query" if defined($query);

  my $fragment = exists($from{fragment}) ? $from{fragment} : $self->fragment;
  $string .= "#$fragment" if defined($fragment);

  $string
}

sub BUILD {
  my ($self) = @_;
  #
  # Parse and get result
  #
  my $recognizerInterface = MarpaX::ESLIF::URI::Generic::RecognizerInterface->new($self->input);
  my $valueInterface = MarpaX::ESLIF::URI::Generic::ValueInterface->new();
  $_GRAMMAR->parse($recognizerInterface, $valueInterface) || croak 'Parse failure';

  my $result = $valueInterface->getResult || croak "Invalid input";
  foreach (keys %{$result}) {
    $self->$_($result->{$_})
  }
}

sub is_absolute {
  my ($self) = @_;

  (defined($self->scheme) && ! defined($self->fragment)) ? 1 : 0
}

sub stringify {
  my ($self) = @_;

  $self->input
}

sub clone {
  my ($self) = @_;

  __PACKAGE__->new("$self")
}

sub base {
  my ($self) = @_;

  if ($self->is_absolute) {
    #
    # We are already a base URI
    #
    $self->clone
  } else {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI from $self: there is no scheme" unless defined $self->scheme;
    #
    # Here per def there is a fragment, the base URI is the current URI without this fragment
    #
    __PACKAGE__->new($self->reconstruct(fragment => undef))
  }
}

sub rebase {
  my ($R, $Base, $strict) = @_;

  $R    = __PACKAGE__->new("$R")    unless (blessed($R)    // '') eq __PACKAGE__;
  $Base = __PACKAGE__->new("$Base") unless (blessed($Base) // '') eq __PACKAGE__;

  croak 'Base must be an absolute URI' unless $Base->is_absolute;

  my (%R, %Base);
  map { $R{$_}    = $R->$_    } qw/scheme authority path query segments/;
  map { $Base{$_} = $Base->$_ } qw/scheme authority path query segments/;
  #
  # A non-strict parser may ignore a scheme in the reference
  # if it is identical to the base URI's scheme.
  #
  # Per def $Base{scheme} is defined
  # $R{scheme} may be undefined
  #
  if ((! $strict) && defined($R{scheme}) && ($R{scheme} eq $Base{scheme})) {
    $R{scheme} = undef
  }

  my %T;
  if (defined($R{scheme})) {
    $T{scheme}    = $R{scheme};
    $T{authority} = $R{authority};
    $T{path}      = __PACKAGE__->remove_dot_segments($R{path});
    $T{query}     = $R{query}
  } else {
    if (defined($R{authority})) {
      $T{authority} = $R{authority};
      $T{path}      = __PACKAGE__->remove_dot_segments($R{path});
      $T{query}     = $R{query}
    } else {
      if (! length($R{path})) {
        $T{path} = $Base{path};
        if (defined($R{query})) {
          $T{query} = $R{query}
        } else {
          $T{query} = $Base{query}
        }
      } else {
        if (substr($R{path}, 0, 1) eq '/') {
          $T{path} = __PACKAGE__->remove_dot_segments($R{path})
        } else {
          $T{path} = __PACKAGE__->merge($Base, $R);
          $T{path} = __PACKAGE__->remove_dot_segments($T{path})
        }
        $T{query} = $R{query};
      }
      $T{authority} = $Base{authority};
    }
    $T{scheme} = $Base{scheme};
  }

  $T{fragment} = $R{fragment};

  #
  # We construct a full stringified version of T
  #
  my $T = '';
  $T .= $T{scheme} . ':' if (defined($T{scheme}));
  $T .= '//' . $T{authority} if (defined($T{authority}));
  $T .= $T{path};
  $T .= '?' . $T{query} if (defined($T{query}));
  $T .= '#' . $T{fragment} if (defined($T{fragment}));

  return __PACKAGE__->new($T)
}

sub merge {
  my ($class, $Base, $R) = @_;

  if (defined($Base->authority) && ! length($Base->path)) {
    return '/' . $R->path
  } else {
    my $path = $Base->path;                # If empty then ./..
    my @segment = @{$Base->segments};      # ../. no segment -;
    if (@segment) {
      my $quote_last_segment = quotemeta($segment[-1]);
      $path =~ s/$quote_last_segment$//;
    }
    return $path . $R->path
  }
}

sub remove_dot_segments {
  my ($class, $input) = @_;

  my $output = '';
  while (length($input) > 0) {
    if (($input =~/^\.\.\//p) || ($input =~ /^\.\//p)) {
      substr($input, 0, length(${^MATCH}), '')
    } elsif (($input =~/^\/\.\//p) || ($input =~ /^\/\.(?:\/|\z)/p)) {
      substr($input, 0, length(${^MATCH}), '/')
    } elsif (($input =~/^\/\.\.\//p) || ($input =~ /^\/\.\.(?:\/|\z)/p)) {
      substr($input, 0, length(${^MATCH}), '/');
      $output =~ s/\/?[^\/]*$//
    } elsif ($input eq '.') {
      substr($input, 0, 1, '')
    } elsif ($input eq '..') {
      substr($input, 0, 2, '')
    } else {
    }
  }
}

sub compare {
    my ($self1, $self2, $swap) = @_;

    return "$self1" cmp "$self2" # TO DO
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
                           | <path empty>                                                   action => path # Marpa does not call <path empty> rule (!?)

<URI reference>          ::= <URI>
                           | <relative ref>

<absolute URI>           ::= <scheme> ":" <hier part> <URI query>

<relative ref>           ::= <relative part> <URI query> <URI fragment>

<relative part>          ::= "//" <authority> <path abempty>
                           | <path absolute>
                           | <path noscheme>
                           | <path empty>                                                    action => path # Marpa does not call <path empty> rule (!?)

<scheme>                 ::= <ALPHA> <scheme trailer>                                        action => scheme
<scheme trailer unit>    ::= <ALPHA> | <DIGIT> | "+" | "-" | "."
<scheme trailer>         ::= <scheme trailer unit>*

<authority userinfo>     ::= <userinfo> "@"
<authority userinfo>     ::=
<authority port>         ::= ":" <port>
<authority port>         ::=
<authority>              ::= <authority userinfo> <host> <authority port>                    action => authority
<userinfo unit>          ::= <unreserved> | <pct encoded> | <sub delims> | ":"
<userinfo>               ::= <userinfo unit>*
#
# The syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.
#
<host>                   ::= <IP literal>            rank =>  0
                           | <IPv4address>           rank => -1
                           | <reg name>              rank => -2
<port>                   ::= <DIGIT>*

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
<path abempty>           ::= <path abempty unit>*                                           action => path
<path absolute>          ::= "/"                                                            action => path
                           | "/" <segment nz> <path abempty>                                action => path
<path noscheme>          ::= <segment nz nc> <path abempty>                                 action => path
<path rootless>          ::= <segment nz> <path abempty>                                    action => path
<path empty>             ::=                                                                # action => path

<segment>                ::= <pchar>*                                                       action => segment
<segment nz>             ::= <pchar>+                                                       action => segment
<segment nz nc unit>     ::= <unreserved> | <pct encoded> | <sub delims> | "@" # non-zero-length segment without any colon ":"
<segment nz nc>          ::= <segment nz nc unit>+                                          action => segment

<pchar>                  ::= <unreserved> | <pct encoded> | <sub delims> | ":" | "@"

<query unit>             ::= <pchar> | "/" | "?"
<query>                  ::= <query unit>*                                                  action => query

<fragment unit>          ::= <pchar> | "/" | "?"
<fragment>               ::= <fragment unit>*                                               action => fragment

<pct encoded>            ::= "%" <HEXDIG> <HEXDIG> #                                          action => pct_encoded

<unreserved>             ::= <ALPHA> | <DIGIT> | "-" | "." | "_" | "~"
<reserved>               ::= <gen delims> | <sub delims>
<gen delims>             ::= ":" | "/" | "?" | "#" | "[" | "]" | "@"
<sub delims>             ::= "!" | "$" | "&" | "'" | "(" | ")"
                           | "*" | "+" | "," | ";" | "="

<HEXDIG many>            ::= <HEXDIG>+
<ALPHA>                  ::= [A-Za-z]
<DIGIT>                  ::= [0-9]
<HEXDIG>                 ::= [0-9A-Fa-f]          # case insensitive
