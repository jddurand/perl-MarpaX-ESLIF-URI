package MarpaX::ESLIF::URI::Role::URI;

# ABSTRACT: URI role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

# <URI>                    ::= <scheme> ":" <hier part> <URI query> <URI fragment>
# <hier part>              ::= "//" <authority> <path abempty>
#                            | <path absolute>
#                            | <path rootless>
#                            | <path empty>

requires 'scheme';
requires 'fragment';

with qw/MarpaX::ESLIF::URI::Role/;

1;
