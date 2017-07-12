package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo;
use strictures 2;
use MarpaX::ESLIF::URI::Grammar;
use Types::Standard qw/Bool/;
use overload
  '""' => 'stringify',
  fallback => 1;

has 'is_absolute' => (is => 'rwp', isa => Bool);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    if (@args == 1 && ! ref $args[0]) {
      return MarpaX::ESLIF::URI::Grammar->parse($args[0]);
    } else {
      return $class->$orig(@args)
    }
};

sub BUILD {
  my ($self) = @_;

  #
  # Well, no need to reparse are 'URI reference': an absolute URI is an URI that:
  # - have a scheme
  # - do not have a fragment

  $self->_set_is_absolute((defined($self->scheme) && ! defined($self->fragment)) ? 1 : 0)
}

sub stringify {
    my ($self) = @_;

    my $string = '';

    my $scheme   = $self->scheme;
    $string .= "$scheme:" if defined($scheme);

    my $authority = $self->authority;
    $string .= "//$authority" if defined($authority);

    $string .= $self->path;

    my $query = $self->query;
    $string .= "?query" if defined($query);

    my $fragment = $self->fragment;
    $string .= "#$fragment" if defined($fragment);

    return $string
}

sub compare {
    my ($self1, $self2, $swap) = @_;

    return "$self1" cmp "$self2" # TO DO
}

with qw/MarpaX::ESLIF::URI::Role::Scheme
        MarpaX::ESLIF::URI::Role::Authority
        MarpaX::ESLIF::URI::Role::Path
        MarpaX::ESLIF::URI::Role::Query
        MarpaX::ESLIF::URI::Role::Fragment/;

1;
