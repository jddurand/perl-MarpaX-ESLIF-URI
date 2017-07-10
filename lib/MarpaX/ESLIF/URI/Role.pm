package MarpaX::ESLIF::URI::Role;

# ABSTRACT: Generic role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

use Carp qw/croak/;
use Types::Standard qw/Str Undef ArrayRef/;

#
# The three main entry points: URI, Reference and Absolute all have
# in common these three attributes
#
has 'authority' => (is => 'rw', isa => Str|Undef);                         # String or undef
has 'path'      => (is => 'rw', isa => Str,     , default => sub { '' });  # String, always defined
has 'query'     => (is => 'rw', isa => Str|Undef);                         # Sring or undef
#
# They all share the same constraint:
# When authority is present, the path must either be empty or begin with a slash ("/") character.  When
# authority is not present, the path cannot begin with two slash characters ("//").
#
after authority => sub {
    my ($self, $authority) = @_;

    my $path = $self->path;
    if (defined($authority)) {
        croak 'When authority is present, path must either be empty or begin with a slash ("/") character' unless ((! length($path)) || substr($path, 0, 1) eq '/')
    } else {
        croak 'When authority is not present, path cannot begin with two slash characters ("//")' if (substr($path, 0, 2) eq '//')
    }
}

#
# Default stringification
#
sub toString {
    my ($self) = @_;

#       example.com:8042/over/there?name=ferret
#       \______________/\_________/ \_________/
#              |            |            |     
#          authority       path        query   

    my $authority = $self->authority;
    my $string = $authority if (defined($authority));

    $string .= $self->path;

    my $query = $self->query;
    $string .= '?' . $query if (defined($query));

    return $string
}

requires 'encode';       # Producer
requires 'decode';       # Consumer

1;
