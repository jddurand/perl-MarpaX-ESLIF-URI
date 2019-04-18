use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::tel;

# ABSTRACT: URI::tel syntax as per RFC3966, RFC4694, RFC4715

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

has '_subscriber'    => (is => 'rwp');
has '_number'        => (is => 'rwp');
has '_ext'           => (is => 'rwp');
has '_isub'          => (is => 'rwp');
has '_isub_encoding' => (is => 'rwp');
has '_phone_context' => (is => 'rwp');
has '_rn'            => (is => 'rwp');
has '_rn_context'    => (is => 'rwp');
has '_cic'           => (is => 'rwp');
has '_cic_context'   => (is => 'rwp');
has '_parameters'    => (is => 'rwp', default => sub { { origin => [], decoded => [], normalized => [] } });
#
# All attributes starting with an underscore are the result of parsing
#
__PACKAGE__->_generate_actions(qw/_subscriber/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::tel inherits, and eventually overwrites some, methods of MarpaX::ESLIF::URI::_generic.

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

=head2 $self->number($type)

Returns the global or local number digits. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub number {
    my ($self, $type) = @_;

    return $self->_generic_getter('_number', $type)
}

=head2 $self->ext($type)

Returns the extension, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub ext {
    my ($self, $type) = @_;

    return $self->_generic_getter('_ext', $type)
}

=head2 $self->isub($type)

Returns the isdn sub-address, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub isub {
    my ($self, $type) = @_;

    return $self->_generic_getter('_isub', $type)
}

=head2 $self->isub_encoding($type)

Returns the isdn sub-address encoding for transmission, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub isub_encoding {
    my ($self, $type) = @_;

    return $self->_generic_getter('_isub_encoding', $type)
}

=head2 $self->phone_context($type)

Returns the phone context, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub phone_context {
    my ($self, $type) = @_;

    return $self->_generic_getter('_phone_context', $type)
}

=head2 $self->rn($type)

Returns the rn, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub rn {
    my ($self, $type) = @_;

    return $self->_generic_getter('_rn', $type)
}


=head2 $self->rn_context($type)

Returns the rn context, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub rn_context {
    my ($self, $type) = @_;

    return $self->_generic_getter('_rn_context', $type)
}


=head2 $self->cic($type)

Returns the cic, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub cic {
    my ($self, $type) = @_;

    return $self->_generic_getter('_cic', $type)
}

=head2 $self->cic_context($type)

Returns the cic context, if any. May be undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub cic_context {
    my ($self, $type) = @_;

    return $self->_generic_getter('_cic_context', $type)
}

=head2 $self->parameters($type)

Returns the parameters as an array of hashes that have the form { key => $key, value => $value }, where value may be undef, and with respect to the order of appearance in the URI. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub parameters {
    my ($self, $type) = @_;

    return $self->_generic_getter('_parameters', $type)
}

# ------------------------
# Specific grammar actions
# ------------------------
sub __normalize_number {
    my ($self, @args) = @_;

    my $rc = $self->__concat(@args);
    #
    # Normalizer number is without the visual separators
    #
    $rc->{normalized} =~ s/[-.()]//g;

    return $rc
}

sub __number {
    my ($self, @args) = @_;

    return $self->{_number} = $self->__normalize_number(@args);
}

sub __pname {
    my ($self, @args) = @_;
    #
    # Normalized <pname> is case-insensitive.
    #
    my $rc = $self->__concat(@args);
    $rc->{normalized} = lc($rc->{normalized});

    return $rc
}

sub __parameter_cmp {
    my ($parametera, $parameterb) = @_;

    my $keya = $parametera->{key};
    my $keyb = $parameterb->{key};

    if (($keya eq 'ext') or ($keya eq 'isub')) {
        if (($keyb eq 'ext') or ($keyb eq 'isub')) {
            #
            # ext will naturally come before isub
            #
            return $keya cmp $keyb
        } else {
            #
            # ext or isub always comes first
            #
            return 1
        }
    } elsif ($keya eq 'phone-context') {
        #
        # phone-context always appear after ext or isub, if any, and before any other parameter
        #
        if (($keyb eq 'ext') or ($keyb eq 'isub')) {
            return -1
        } else {
            return 1
        }
    } elsif ($keyb eq 'phone-context') {
        #
        # phone-context always appear after ext or isub, if any, and before any other parameter
        #
        if (($keya eq 'ext') or ($keya eq 'isub')) {
            return 1
        } else {
            return -1
        }
    } else {
        return $keya cmp $keyb
    }
}

sub __parameter {
    my ($self, $semicolumn, $pname, $equal, $pvalue) = @_; # $equal and $pvalue may be undef
    #
    # Each parameter name ("pname"), the ISDN subaddress, the 'extension',
    # and the 'context' MUST NOT appear more than once.  The 'isdn-
    # subaddress' or 'extension' MUST appear first, if present, followed by
    # the 'context' parameter, if present, followed by any other parameters
    # in lexicographical order.
    #
    my $concat = $self->__concat($semicolumn, $pname, $equal, $pvalue);

    foreach my $type (qw/normalized origin decoded/) { # We normalized first to do the checks first -;
        my $key = $pname->{$type};
        my $value = defined($pvalue) ? $pvalue->{$type} : undef;
        #
        # We compare using the normalized type
        #
        if ($type eq 'normalized') {
            my $keyNotNormalized = $pname->{origin};
            #
            # A parameter must not appear more than once - this makes sure that
            # reserved keywords coming from unwanted rule par ::= parameter are
            # catched, e.g. 'Ext' alone
            #
            if (grep {$_ eq $key} map { $_->{key} } @{$self->_parameters->{$type}}) {
                croak "Parameter '$keyNotNormalized' already exists"
            } elsif (@{$self->_parameters->{$type}}) {
                if (($key eq 'ext') || ($key eq 'isub')) {
                    #
                    # isub or ext must appear first
                    #
                    my $previouskey = $self->_parameters->{$type}->[-1]->{key};
                    if (($previouskey ne 'ext') && ($previouskey ne 'isub')) {
                        my $previouskeyNotNormalized = $self->_parameters->{origin}->[-1]->{key};
                        croak "Parameter '$keyNotNormalized' must appear before '$previouskeyNotNormalized'"
                    }
                } elsif ($key eq 'phone-context') {
                    #
                    # context parameter must be after isub or ext if present
                    #
                    my $max = -1;
                    my $firstkey = $self->_parameters->{$type}->[0]->{key};
                    if (($firstkey eq 'ext') || ($firstkey eq 'isub')) {
                        if ($#{$self->_parameters->{$type}} > 0) {
                            my $secondkey = $self->_parameters->{$type}->[1]->{key};
                            if (($secondkey eq 'ext') || ($secondkey eq 'isub')) {
                                $max = 1;
                            } else {
                                $max = 0;
                            }
                        }
                    }
                    if (($max >= 0) && ($#{$self->_parameters->{$type}} != $max)) {
                        my $targetkeyNotNormalized = $self->_parameters->{origin}->[$max]->{key};
                        croak "Parameter '$keyNotNormalized' must appear after '$targetkeyNotNormalized'"
                    }
                } else {
                    #
                    # Any other must be in lexicographical order
                    #
                    my $previouskey = $self->_parameters->{$type}->[-1]->{key};
                    if (($previouskey ne 'ext') && ($previouskey ne 'isub') && ($previouskey ne 'phone-context')) {
                        if (($previouskey cmp $key) >= 0) {
                            croak "Parameter '$keyNotNormalized' must appear before previous parameter '$previouskey'"
                        }
                    }
                }
            }
        }

        push(@{$self->_parameters->{$type}}, { key => $key, value => $value });
    }

    return $concat
}

my $semicolumn = { normalized => ';', origin => ';',  decoded => ';' };
my $equal      = { normalized => '=', origin => '=',  decoded => '=' };
sub __add_parameter {
    my ($self, $name, $pvalue) = @_;

    my %pname;
    foreach my $type (qw/normalized origin decoded/) { # We normalized first to do the checks first -;
        $pname{$type} = $name->{$type};
        substr($pname{$type},  0, 1, '') if substr($pname{$type},  0, 1) eq ';';
        substr($pname{$type}, -1, 1, '') if substr($pname{$type}, -1, 1) eq '=';
    }

    return $self->__parameter($semicolumn, \%pname, $equal, $pvalue)
}

sub __ext {
    my ($self, $ext, $pvalue) = @_;

    return $self->__add_parameter($ext, $self->{_ext} = $pvalue)
}

sub __isub {
    my ($self, $isub, $pvalue) = @_;

    return $self->__add_parameter($isub, $self->{_isub} = $pvalue)
}

sub __phone_context {
    my ($self, $phone_context, $pvalue) = @_;

    return $self->__add_parameter($phone_context, $self->{_phone_context} = $pvalue)
}

sub __rn {
    my ($self, $rn, $pvalue) = @_;

    return $self->__add_parameter($rn, $self->{_rn} = $pvalue)
}

sub __rn_context {
    my ($self, $rn_context, $pvalue) = @_;

    return $self->__add_parameter($rn_context, $self->{_rn_context} = $pvalue)
}

sub __npdi {
    my ($self, $npdi) = @_;

    return $self->__add_parameter($npdi)
}

sub __cic {
    my ($self, $cic, $pvalue) = @_;

    return $self->__add_parameter($cic, $self->{_cic} = $pvalue)
}

sub __cic_context {
    my ($self, $cic_context, $pvalue) = @_;

    return $self->__add_parameter($cic_context, $self->{_cic_context} = $pvalue)
}

sub __isub_encoding {
    my ($self, $isub_encoding, $pvalue) = @_;

    return $self->__add_parameter($isub_encoding, $self->{_isub_encoding} = $pvalue)
}

=head1 NOTES

=over

=item

Errata L<203|https://www.rfc-editor.org/errata/eid203> has been applied.

=item

Parameters are NOT reordered. So, since RFC3966 states that they B<MUST> appear lexicographically sorted (except for C<ext>, C<isdn> and C<phone-context>), the parsing will fail in the input does not respect this sorting rule.

=item

RFC4694 requires compliance with L<E.164|https://en.wikipedia.org/wiki/E.164> but this is not checked.

=item

L<ITU-T Q.1912.5|https://www.itu.int/rec/T-REC-Q.1912.5-201801-I> suggests that the C<isub encoding value> contains what the old L<RFC2396|https://tools.ietf.org/html/rfc2396> called the URI character, i.e. C<uric>.

=back

=head1 SEE ALSO

L<RFC3966|https://tools.ietf.org/html/rfc3966>, L<RFC4694|https://tools.ietf.org/html/rfc4694>, L<RFC4715|https://tools.ietf.org/html/rfc4715>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc3966#section-3
#
<telephone URI>           ::= <telephone scheme> ":" <telephone subscriber>                   action => _action_string

<telephone scheme>        ::= "tel":i                                                         action => _action_scheme

<telephone subscriber>    ::= <global number>                                                 action => _action_subscriber
                            | <local number>                                                  action => _action_subscriber

<global number>           ::= <global number digits> pars
<local number>            ::= <local number digits> pars context pars
pars                      ::= par*
par                       ::= parameter
                            | extension
                            | <isdn subaddress>
<isdn subaddress>         ::= ";isub=" <paramchar many>                                       action => __isub
extension                 ::= ";ext=" <phonedigit many>                                       action => __ext
context                   ::= ";phone-context=" descriptor                                    action => __phone_context
descriptor                ::= domainname
                            | <global number digits>
#
# The <global number digits> and <local number digits> are ambiguous because
# <phonedigit> contains DIGIT, and <phonedigit hex> contains HEXDIG
#
# What W3C wanted to express with <global number digits> is that it must contains
# at least one DIGIT everywhere
# Original expression was: <global number digits>    ::= "+" <phonedigit any> DIGIT <phonedigit any>
# Fixed expression is taking advantage of the greedy nature of regexp:
                           <global number digits>    ::= /\+[0-9.()-]*[0-9][0-9.()-]*/      action => __number

#
# Same remark for <local number digits>: <phonedigit hex>
# Original expression was: <local number digits>     ::= <phonedigit hex any> <local number digits sep> <phonedigit hex any>
# Fixed expression is:
                           <local number digits>     ::= /[0-9A-Fa-f*#.()-]*[0-9A-Fa-f*#][0-9A-Fa-f*#.()-]*/ action => __number
# <local number digits sep> ::= HEXDIG
#                             | "*"
#                             | "#"
<domainlabel and dot>     ::= domainlabel "."
<domainlabels>            ::= <domainlabel and dot>*
domainname                ::= <domainlabels> toplabel "."
                            | <domainlabels> toplabel
domainlabel               ::= /[A-Za-z0-9-](?:[A-Za-z0-9-]*[A-Za-z0-9])?/
toplabel                  ::= /[A-Za-z](?:[A-Za-z0-9-]*[A-Za-z0-9])?/
parameter                 ::= ";" pname                                                     action => __parameter
                            | ";" pname "=" pvalue                                          action => __parameter
pname                     ::= /[A-Za-z0-9-]+/                                               action => __pname
pvalue                    ::= <paramchar many>
paramchar                 ::= <param unreserved>
                            | <tel unreserved>
                            | <pct encoded>
<paramchar many>          ::= paramchar+
<tel unreserved>          ::= alphanum
                            | mark
mark                      ::= [-_.!~*'()]
<param unreserved>        ::= [\[\]/:&+$]
phonedigit                ::= DIGIT
                            | <visual separator>
<phonedigit many>         ::= phonedigit+                                                   action => __normalize_number
<visual separator>        ::= [-.()]
alphanum                  ::= [A-Za-z0-9]
<tel reserved>            ::= [;/?:@&=+$,]

#
## RFC 4694
#
parameter                 ::= rn
                            | cic
                            | npdi
rn                        ::= ";rn=" <global rn>                                            action => __rn
                            | ";rn=" <local rn>                                             action => __rn
npdi                      ::= ";npdi"                                                       action => __npdi
cic                       ::= ";cic=" <global cic>                                          action => __cic
                            | ";cic=" <local cic>                                           action => __cic
<global rn>               ::= <global hex digits>
# The first "hex-phonedigit" value in "local-rn" MUST be a hex-decimal digit.
<local rn>                ::= HEXDIG <hex phonedigit any> <rn context>
<rn context>              ::= ";rn-context=" <rn descriptor>                                action => __rn_context
<rn descriptor>           ::= domainname
                            | <global hex digits>
<global hex digits>       ::= "+" /[0-9]{1,3}/ <hex phonedigit any>
<hex phonedigit>          ::= HEXDIG
                            | <visual separator>
<global cic>              ::= <global hex digits>
# The first "hex-phonedigit" value in "local-rn" MUST be a hex-decimal digit.
<local cic>               ::= HEXDIG <hex phonedigit any> <cic context>
<cic context>             ::= ";cic-context=" <rn descriptor>                               action => __cic_context

<hex phonedigit any>      ::= <hex phonedigit>*                                             action => __normalize_number

#
# RFC4715
#
parameter                 ::= ";isub-encoding=" <isub encoding value>                       action => __isub_encoding
#
# No need to set "nsap-ia5", "nsap-bcd" or "nsap" explicitely: rfc4715token will catch them
<isub encoding value>     ::= rfc4715token
rfc4715token              ::= uric+
uric                      ::= <unreserved>
                            | <pct encoded>
                            | [;?:@&=+$,/]
