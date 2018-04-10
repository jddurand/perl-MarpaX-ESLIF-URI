use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::tag;

# ABSTRACT: URI::tag syntax as per RFC4151

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::mailto'; # inherit <addr spec> semantic

has '_entity'    => (is => 'rwp', default => sub { { origin => '', decoded => '', normalized => '' } }); # Default is empty path ./..
has '_authority' => (is => 'rwp', default => sub { { origin => '', decoded => '', normalized => '' } }); # Default is empty path ./..
has '_date'      => (is => 'rwp', default => sub { { origin => '', decoded => '', normalized => '' } }); # Default is empty path ./..

#
# All attributes starting with an underscore are the result of parsing
#
__PACKAGE__->_generate_actions(qw/_entity/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::tag inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

=head2 $class->bnf

Overwrites parent's bnf implementation. Returns the BNF used to parse the input.

=cut

sub bnf {
  my ($class) = @_;

  join("\n", $BNF, MarpaX::ESLIF::URI::mailto->bnf) # We merge with mailto: BNF to get the <addr spec> syntax from it
};

=head2 $class->grammar

Overwrite parent's grammar implementation. Returns the compiled BNF used to parse the input as MarpaX::ESLIF::Grammar singleton.

=cut

sub grammar {
  my ($class) = @_;

  return $GRAMMAR;
}

=head2 $self->entity($type)

Returns the tag entity. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub entity {
    my ($self, $type) = @_;

    return $self->_generic_getter('_entity', $type)
}

# ------------------------
# Specific grammar actions
# ------------------------
sub __entity {
    my ($self, $authorityName, $comma, $date) = @_;

    my $concat = $self->__concat($authorityName, $comma, $date);
    map { $self->_entity->{$_} = $concat->{$_} } qw/origin decoded normalized/;

    return $concat
}

sub __authority_DNSname {
    my ($self, $DNSname) = @_;

    my $concat = $self->__concat($DNSname);
    map { $self->_authority->{$_} = $concat->{$_} } qw/origin decoded normalized/;

    return $concat
}

sub __authority_emailAddress {
    my ($self, $emailAddress) = @_;

    my $concat = $self->__concat($emailAddress);
    map { $self->_authority->{$_} = $concat->{$_} } qw/origin decoded normalized/;

    return $concat
}

sub __date {
    my ($self, @components) = @_;

    my $concat = $self->__concat(@components);
    map { $self->_date->{$_} = $concat->{$_} } qw/origin decoded normalized/;

    return $concat
}

# -------------
# Normalization
# -------------

=head1 NOTES

Errata L<1485|https://www.rfc-editor.org/errata/eid1485> has been applied.

=head1 SEE ALSO

L<RFC4151|https://tools.ietf.org/html/rfc4151>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc4151#section-2.1
#
<tag URI>                 ::= <tag scheme> ":" <tag entity> ":" <tag specific> <tag fragment> action => _action_string

<tag scheme>              ::= "tag":i                                                         action => _action_scheme

<tag entity>              ::= <tag authority> "," <tag date>                                  action => __entity
<tag authority>           ::= DNSname                                                         action => __authority_DNSname
                            | emailAddress                                                    action => __authority_emailAddress
<tag date>                ::= year                                                            action => __date
                            | year "-" month                                                  action => __date
                            | year "-" month "-" day                                          action => __date
year                      ::= DIGIT DIGIT DIGIT DIGIT
month                     ::= DIGIT DIGIT
day                       ::= DIGIT DIGIT
DNSname                   ::= DNScomp+ separator => "."
DNScomp                   ::= alphaNum
                            | alphaNum DNSCompInner alphaNum
DNSCompInnerUnit          ::= alphaNum
                            | "-"
DNSCompInner              ::= DNSCompInnerUnit*
emailAddress              ::= <addr spec>
alphaNum                  ::= DIGIT
                            | ALPHA
<tag specific>            ::= <hier part> <URI query>
<tag fragment>            ::= <URI fragment>

#
# <addr spec> is picked from the mailto bnf
#
