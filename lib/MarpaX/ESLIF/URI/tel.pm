use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::tel;

# ABSTRACT: URI::tag syntax as per RFC3966

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

has '_subscriber'    => (is => 'rwp');
has '_global_number' => (is => 'rwp');
has '_local_number'  => (is => 'rwp');
has '_context'       => (is => 'rwp');
has '_descriptor'    => (is => 'rwp');
has '_domainname'    => (is => 'rwp');
has '_toplabel'      => (is => 'rwp');
has '_parameters'    => (is => 'rwp', default => sub { { origin => [], decoded => [], normalized => [] } });
#
# All attributes starting with an underscore are the result of parsing
#
__PACKAGE__->_generate_actions(qw/_subscriber _global_number _local_number _context _descriptor _domainname _toplabel/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::tag inherits, and eventually overwrites some, methods of MarpaX::ESLIF::URI::_generic.

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

# ------------------------
# Specific grammar actions
# ------------------------
sub __number {
    my ($self, @args) = @_;

    my $rc = $self->__concat(@args);
    #
    # Normalizer number is without the visual separators
    #
    $rc->{normalized} =~ s/[-.()]//g;

    return $rc
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

=head1 NOTES

=over

=item Errata L<203|https://www.rfc-editor.org/errata/eid203> has been applied.

=item

Parameters other than isdn subaddress, extension and phone context will be reordered lexicographically using their normalized key (the original RFC states that they <B>MUST</B> appear originally in the correct order)

=back

=head1 SEE ALSO

L<RFC3966|https://tools.ietf.org/html/rfc3966>, L<MarpaX::ESLIF::URI::_generic>

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

<global number>           ::= <global number digits> pars                                     action => _action_global_number
<local number>            ::= <local number digits> pars context pars                         action => _action_local_number
pars                      ::= par*
par                       ::= parameter
                            | extension                                             rank => 1
                            | <isdn subaddress>                                     rank => 1
<isdn subaddress>         ::= ";" "isub" "=" <paramchar many>                                 action => __parameter
extension                 ::= ";" "ext" "=" <phonedigit many>                                 action => __parameter
context                   ::= ";" "phone-context" "=" descriptor                              action => __parameter
descriptor                ::= domainname                                                      action => _action_descriptor
                            | <global number digits>                                          action => _action_descriptor
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
domainname                ::= <domainlabels> toplabel "."                                   action => _action_domainname
                            | <domainlabels> toplabel                                       action => _action_domainname
domainlabel               ::= /[A-Za-z0-9-](?:[A-Za-z0-9-]*[A-Za-z0-9])?/
toplabel                  ::= /[A-Za-z](?:[A-Za-z0-9-]*[A-Za-z0-9])?/                       action => _action_toplabel
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
<phonedigit many>         ::= phonedigit+                                                   action => __number
<phonedigit hex>          ::= HEXDIG
                            | [*#]
                            | <visual separator>
<phonedigit hex any>      ::= <phonedigit hex>*
<visual separator>        ::= [-.()]
alphanum                  ::= [A-Za-z0-9]
<tel reserved>            ::= [;/?:@&=+$,]
