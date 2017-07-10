package MarpaX::ESLIF::URI::Role::Absolute;

# ABSTRACT: Absolute URI role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

# <absolute URI>           ::= <scheme> ":" <hier part> <URI query>
# <hier part>              ::= "//" <authority> <path abempty>
#                            | <path absolute>
#                            | <path rootless>
#                            | <path empty>

requires 'scheme';

with qw/MarpaX::ESLIF::URI::Role/;

1;
