use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::file;

# ABSTRACT: URI::file syntax as per RFC8089

# AUTHORITY

# VERSION

use parent 'MarpaX::ESLIF::URI::_generic';
use Class::Tiny qw/drive/;
use Class::Method::Modifiers qw/around/;

my $BNF = do { local $/; <DATA> };

around bnf => sub {
  my ($orig, $class) = @_;

  return join("\n", $BNF, $class->$orig)
};

=head1 SEE ALSO

L<RFC8089|https://tools.ietf.org/html/rfc8089>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc8089#section-2
#
<file URI>       ::= <file scheme> ":" <file hier part>

<file scheme>    ::= "file"                                        action => scheme

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

<unc authority>  ::= "//" <file host>                              action => authority
                   | "///" <file host>                             action => authority

<file host>      ::= <inline IP>                                   action => host
                   | IPv4address                                   action => host
                   | <reg name>                                    action => host

<inline IP>      ::= "%5B" <IPv6address> "%5D"
                   | "%5B" <IPvFuture> "%5D"

<file absolute>  ::= "/" <drive letter> <path absolute>

<drive>          ::= ALPHA                                         action => drive

<drive letter>   ::= <drive> ":"
                   | <drive> "|"

<file auth>      ::= <userinfo> "@" <host>                         action => authority
                   |                <host>                         action => authority

<host>           ::= "localhost"                                   action => host
#
# Generic syntax will be appended here
#
