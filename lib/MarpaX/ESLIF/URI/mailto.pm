use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::mailto;

# ABSTRACT: URI::mailto syntax as per RFC6068

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use MarpaX::ESLIF;

extends 'MarpaX::ESLIF::URI::_generic';

has '_to'        => (is => 'rwp', default => sub { {} } );
has '_headers'   => (is => 'rwp', default => sub { {} } );

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

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

=head2 $self->to($type)

Returns the addresses. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub to {
    my ($self, $type) = @_;

    return $self->_generic_getter('_to', $type)
}

=head2 $self->headers($type)

Returns the headers. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub headers {
    my ($self, $type) = @_;

    return $self->_generic_getter('_headers', $type)
}

# ------------------------
# Specific grammar actions
# ------------------------
sub __to {
    my ($self, @args) = @_;

    my $concat = $self->__concat(@args);
    push(@{$self->_to->{origin}},     $concat->{origin});
    push(@{$self->_to->{decoded}},    $concat->{decoded});
    push(@{$self->_to->{normalized}}, $concat->{normalized});
    return $concat
}

sub __header {
    my ($self, @args) = @_;

    my $concat = $self->__concat(@args);
    push(@{$self->_headers->{origin}},     $concat->{origin});
    push(@{$self->_headers->{decoded}},    $concat->{decoded});
    push(@{$self->_headers->{normalized}}, $concat->{normalized});
    return $concat
}

# -------------
# Normalization
# -------------

=head1 SEE ALSO

L<RFC6068|https://tools.ietf.org/html/rfc6068>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc6068#section-2
#
<mailto URI>              ::= <mailto scheme> ":" <mailto hier part>                            action => _action_string # No fragment

<mailto scheme>           ::= "mailto":i                                                        action => _action_scheme

<mailto hier part>        ::=
<mailto hier part>        ::=      <hfields>
                            | <to>
                            | <to> <hfields>

<to>                      ::= <addr spec>+ separator => ','                                     action => _action_path

<mailto query>            ::= <hfield>+ separator => '&'                                        action => _action_query
<hfields>                 ::= "?" <mailto query>

<hfield>                  ::= <hfname> "=" <hfvalue>                                            action => __header
<hfname>                  ::= <qchar>*
<hfvalue>                 ::= <qchar>*

<addr spec>               ::= <local part> "@" <domain>                                         action => __to
<local part>              ::= <dot atom text>
                            | <quoted string>

<dtext no obs any>        ::= <dtext no obs>*
<domain>                  ::= <dot atom text>
                            | "[" <dtext no obs any> "]"
<dtext no obs>            ::= [\x{21}-\x{5A}\x{5E}-\x{7E}] # Printable US-ASCII or characters not including "[", "]", or "\"
<qchar>                   ::= <unreserved>
                            | <pct encoded>
                            | <some delims>
<some delims>             ::= [!$'()*+,;:@]

#
# From https://tools.ietf.org/html/rfc5322#section-3.2.3
#
<dot atom text unit>      ::= <atext>+
<dot atom text>           ::= <dot atom text unit>+ separator => "."
<atext>                   ::= <ALPHA>
                            | <DIGIT>
                            | [!$'*+\-^_`{|}~]
                            | <atext pct encoded>
#
# A number of characters that can appear in <addr-spec> MUST be
# percent-encoded.  These are the characters that cannot appear in
# a URI according to [STD66] as well as "%" (because it is used for
# percent-encoding) and all the characters in gen-delims except "@"
# and ":" (i.e., "/", "?", "#", "[", and "]").  Of the characters
# in sub-delims, at least the following also have to be percent-
# encoded: "&", ";", and "=".  Care has to be taken both when
# encoding as well as when decoding to make sure these operations
# are applied only once.
#
<atext pct encoded>       ::= "%" '2' '5'                                          action => __pct_encoded # %
                            | "%" '2' 'F'                                          action => __pct_encoded # /
                            | "%" '3' 'F'                                          action => __pct_encoded # ?
                            | "%" '2' '3'                                          action => __pct_encoded # #
                            | "%" '5' 'B'                                          action => __pct_encoded # [
                            | "%" '5' 'D'                                          action => __pct_encoded # ]
                            | "%" '2' '6'                                          action => __pct_encoded # &
                            | "%" '3' 'B'                                          action => __pct_encoded # ;
                            | "%" '3' 'D'                                          action => __pct_encoded # =
<quoted string char>      ::=       <qcontent>
                            | <FWS> <qcontent>
<quoted string interior>  ::= <quoted string char>*
<quoted string>           ::=        <DQUOTE> <quoted string interior>       <DQUOTE>
                            |        <DQUOTE> <quoted string interior>       <DQUOTE> <CFWS>
                            |        <DQUOTE> <quoted string interior> <FWS> <DQUOTE>
                            |        <DQUOTE> <quoted string interior> <FWS> <DQUOTE> <CFWS>
                            | <CFWS> <DQUOTE> <quoted string interior>       <DQUOTE>
                            | <CFWS> <DQUOTE> <quoted string interior>       <DQUOTE> <CFWS>
                            | <CFWS> <DQUOTE> <quoted string interior> <FWS> <DQUOTE>
                            | <CFWS> <DQUOTE> <quoted string interior> <FWS> <DQUOTE> <CFWS>
<qcontent>                ::= <qtext>
                            | <quoted pair>
<qtext>                   ::=   [\x{21}\x{23}-\x{5B}\x{5D}-\x{7E}]  # Characters not including "\" or the quote character

#
# From https://tools.ietf.org/html/rfc5322#section-3.2.2
#
<WSP many>                ::= <WSP>+
<WSP any>                 ::= <WSP>*
<FWS>                     ::=                  <WSP many>
                            | <WSP any> <CRLF> <WSP many>
                            | <obs FWS>
<CFWS comment>            ::=       <comment>
                            | <FWS> <comment>
<CFWS comment many>       ::=       <comment>
<CFWS>                    ::= <CFWS comment many>
                            | <CFWS comment many> <FWS>
                            | <FWS>
<comment interior unit>   ::=       <ccontent>
                            | <FWS> <ccontent>
<comment interior units>  ::= <comment interior unit>*
<comment interior>        ::= <comment interior units>
                            | <comment interior units> <FWS>
<comment>                 ::= "(" <comment interior> ")"
<ccontent>                ::= <ctext>
                            | <quoted pair>
                            | <comment>
<ctext>                   ::= [\x{21}-\x{27}\x{2A}-\x{5B}\x{5D}-\x{7E}]
                            | <obs ctext>
<obs ctext>               ::= <obs NO WS CTL>
<obs NO WS CTL>           ::= [\x{01}-\x{08}\x{0B}\x{0C}\x{0E}-\x{1F}\x{7F}]
<obs qp>                  ::= "\\" [\x{00}]
                            | "\\" <obs NO WS CTL>
                            | "\\" <LF>
                            | "\\" <CR>
#
# From https://tools.ietf.org/html/rfc5322#section-3.2.1
#
<quoted pair>             ::= "\\" <VCHAR>
                            | "\\" <WSP>
                            | <obs qp>
#
# From https://tools.ietf.org/html/rfc5234#appendix-B.1
#
<CR>                      ::= [\x{0D}]
<LF>                      ::= [\x{0A}]
<CRLF>                    ::= <CR> <LF>
<DQUOTE>                  ::= [\x{22}]
<VCHAR>                   ::= [\x{21}-\x{7E}]
<WSP>                     ::= <SP>
                            | <HTAB>
<SP>                      ::= [\x{20}]
<HTAB>                    ::= [\x{09}]

#
# From https://tools.ietf.org/html/rfc5322#section-4.2
#
<obs FWS trailer unit>    ::= <CRLF> <WSP many>
<obs FWS trailer>         ::= <obs FWS trailer unit>*
<obs FWS>                 ::= <WSP many> <obs FWS trailer>
#
# Generic syntax will be appended here
#
