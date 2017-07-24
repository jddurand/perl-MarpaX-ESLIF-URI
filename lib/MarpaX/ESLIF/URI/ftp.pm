use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::ftp;

# ABSTRACT: URI::ftp syntax as per RFC1738

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use Class::Method::Modifiers qw/around/;
use MarpaX::ESLIF;
use Net::servent qw/getservbyname/;

extends 'MarpaX::ESLIF::URI::_generic';

has '_user' => (is => 'rwp' );
has '_password' => (is => 'rwp' );

#
# Inherited method
#
__PACKAGE__->_generate_actions(qw/_user _password/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);
my $PORT;
BEGIN {
    my $s = getservbyname('ftp');
    $PORT = $s->port || 20
}

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::ftp inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

=head2 $class->bnf

Overwrites parent's bnf implementation. Returns the BNF used to parse the input.

=cut

sub bnf {
  my ($class) = @_;

  join("\n", $BNF, MarpaX::ESLIF::URI::_generic->bnf)
};

=head2 $class->grammar

Overwrite parent's grammar implementation. Returns the compiled BNF used to parse the input as MarpaX::ESLIF::Grammar singleton.

=cut

sub grammar {
  my ($class) = @_;

  return $GRAMMAR;
}

=head2 $self->user($type)

Returns the user, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut
    
sub user {
    my ($self, $type) = @_;

    return $self->_generic_getter('_user', $type)
}

=head2 $self->password($type)

Returns the password, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut
    
sub password {
    my ($self, $type) = @_;

    return $self->_generic_getter('_password', $type)
}

# -------------
# Normalization
# -------------
around _set__authority => sub {
    my ($orig, $self, $value) = @_;
    #
    # If the port is equal to the default port for a scheme, the normal
    # form is to omit the port subcomponent
    #
    my $port = $self->port;
    if (! defined($port) || ($port eq '') || ($port == $PORT)) {
        my $new_port = $self->_port;
        $new_port->{normalized} = undef;
        $self->_set__port($new_port);
        $value->{normalized} =~ s/:[^:]*//
    }
    $self->$orig($value)
};

=head1 NOTES

The eventual FTP type is left as part of the last segment of C<path>.

=head1 SEE ALSO

L<RFC1738|https://tools.ietf.org/html/rfc1738>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc8089#section-2
#
<ftp URI>                ::= <ftp scheme> ":" <ftp hier part> <URI query> <URI fragment> action => _action_string

<ftp scheme>             ::= "ftp":i                                                     action => _action_scheme

<ftp hier part>          ::= "//" <ftp authority> <path abempty>
                           | <path absolute>
                           | <path rootless>
                           | <path empty>

<ftp authority>          ::= <ftp authority value>                                      action => _action_authority
<ftp authority value>    ::= <ftp authority userinfo> <host> <authority port>

<ftp authority userinfo> ::= <ftp userinfo> "@"
<ftp authority userinfo> ::=

<ftp userinfo>           ::= <ftp userinfo value>                                       action => _action_userinfo
<ftp userinfo>           ::=

<ftp userinfo value>     ::= <ftp user>
                           | <ftp user> ":" <ftp password>

<ftp user unit>          ::= <unreserved> | <pct encoded> | <sub delims>
<ftp user>               ::= <ftp user unit>+                                           action => _action_user
<ftp password unit>      ::= <unreserved> | <pct encoded> | <sub delims>
<ftp password>           ::= <ftp password unit>+                                       action => _action_password
#
# Generic syntax will be appended here
#
