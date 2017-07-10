package MarpaX::ESLIF::URI::Role::Relative;

# ABSTRACT: Relative reference role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

# <relative ref>           ::= <relative part> <URI query> <URI fragment>
# <relative part>          ::= "//" <authority> <path abempty>
#                            | <path absolute>
#                            | <path noscheme>
#                            | <path empty>

requires 'fragment';

with qw/MarpaX::ESLIF::URI::Role/;

1;
