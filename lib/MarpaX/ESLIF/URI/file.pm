use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::file;

# ABSTRACT: URI::file syntax as per RFC8089

# AUTHORITY

# VERSION

use Class::Tiny::Antlers;
use Class::Method::Modifiers qw/around/;
use IO::Socket;
use MarpaX::ESLIF;
use Net::DNS;
use Socket qw/:addrinfo SOCK_RAW NI_NUMERICHOST/;  # Will work with perl >= 5.14

extends 'MarpaX::ESLIF::URI::_generic';

has '_drive' => (is => 'rwp' );

#
# Inherited method
#
__PACKAGE__->_generate_actions(qw/_drive/);

#
# Constants
#
my $BNF = do { local $/; <DATA> };
my $GRAMMAR = MarpaX::ESLIF::Grammar->new(__PACKAGE__->eslif, __PACKAGE__->bnf);

=head1 SUBROUTINES/METHODS

MarpaX::ESLIF::URI::file inherits, and eventually overwrites some, methods or MarpaX::ESLIF::URI::_generic.

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

=head2 $self->drive($type)

Returns the drive, or undef. C<$type> is either 'decoded' (default value), 'origin' or 'normalized'.

=cut

sub drive {
    my ($self, $type) = @_;

    return $self->_generic_getter('_drive', $type)
}

=head2 $self->is_localpath($type)

Returns a true value if the URI refers to a local path, else a false value.

=cut

sub is_localpath {
    my ($self) = @_;

    my $host = $self->host('normalized');
    #
    # A file URI is considered "local" if it has no "file-auth"
    #
    return 1 unless $host;
    #
    # .. or the "file-auth" is the special string "localhost"
    #
    return 1 if $host eq 'localhost';
    #
    # .. or a fully qualified domain name that resolves to the
    # machine from which the URI is being interpreted (Section 2).
    #
    my @resolv_localhost = $self->_resolv('localhost');
    my @resolv_host = $self->_resolv($host);

    return 0;
}

# -------------
# Normalization
# -------------
around _set__drive => sub {
    my ($orig, $self, $value) = @_;

    #
    # Normalized drive is case insensitive and should be uppercased
    #
    $value->{normalized} = uc($value->{normalized});
    $self->$orig($value)
};

# ---------
# Internals
# ---------
sub _resolv {
    my ($self, $hostname) = @_;

    my @rc = ();

    #
    # 1. Try with Socket's getaddrinfo/getnameinfo first
    #
    print STDERR "===========> [getaddrinfo] $hostname ?\n";
    my ($err, @res) = getaddrinfo($hostname, "", { socktype => SOCK_RAW });
    if ($err) {
        print STDERR "............ [getaddrinfo] Cannot getaddrinfo $hostname, $err\n";
        return '';
    }
    foreach my $ai (@res) {
        my ($err, $ipaddr) = getnameinfo($ai->{'addr'}, NI_NUMERICHOST, NIx_NOSERV);
        if ($err) {
            print STDERR "............ [getaddrinfo] Cannot getnameinfo " . $ai->{'addr'} . ", $err\n";
            next;
        }
        print STDERR "............ [getaddrinfo] Got $ipaddr\n";
        push(@rc, $ipaddr);
    }
    # return @rc if @rc;
    #
    # 2. Try with Net::DNS
    #
    print STDERR "............ [Net::DNS::Resolver] $hostname ?\n";
    my $res = Net::DNS::Resolver->new;
    my $query = $res->search($hostname);
    if ($query) {
        foreach my $rr ($query->answer) {
            next unless $rr->type eq "A";
            my $ipaddr = $rr->address;
            print STDERR "............ [Net::DNS::Resolver] Got $ipaddr\n";
            push(@rc, $ipaddr);
        }
    } else {
        print STDERR "............ [Net::DNS::Resolver] Cannot resolv " . $res->errorstring . "\n";
    }
    return @rc;
}

=head1 SEE ALSO

L<RFC8089|https://tools.ietf.org/html/rfc8089>, L<MarpaX::ESLIF::URI::_generic>

=cut

1;

__DATA__
#
# Reference: https://tools.ietf.org/html/rfc8089#section-2
#
<file URI>       ::= <file scheme> ":" <file hier part>            action => _action_string

<file scheme>    ::= "file":i                                      action => _action_scheme

<file hier part> ::= "//" <auth path>
                   | <local path>

#
# <file absolute> is generating ambiguity
#
<auth path>      ::= <file auth> <path absolute>
                   |             <path absolute>
                   | <file auth> <file absolute>         rank => 1
                   |             <file absolute>         rank => 1
                   | <unc authority> <path absolute>

<local path>     ::= <drive letter> <path absolute>                action => _action_path
                   |                <path absolute>
                   |                <file absolute>      rank => 1

<unc authority>  ::= "//" <file host>                              action => _action_authority
                   | "///" <file host>                             action => _action_authority

<file host>      ::= <inline IP>                                   action => _action_host
                   | IPv4address                                   action => _action_host
                   | <reg name>                                    action => _action_host

<inline IP>      ::= "%5B" <IPv6address> "%5D"
                   | "%5B" <IPvFuture> "%5D"

<file absolute>  ::= "/" <drive letter> <path absolute>            action => _action_path

<drive>          ::= ALPHA                                         action => _action_drive

<drive letter>   ::= <drive> ":"                                   action => __segment
                   | <drive> "|"                                   action => __segment

<file auth>      ::= <userinfo> "@" <host>                         action => _action_authority
                   |                <host>                         action => _action_authority

<host>           ::= "localhost"                                   action => _action_host
#
# Generic syntax will be appended here
#
