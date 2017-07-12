package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo;
use strictures 2;
use MarpaX::ESLIF::URI::Grammar;
use Types::Standard qw/Bool/;
use URI::Escape qw/uri_escape/;
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
  # An absolute URI is an URI that:
  # - have a scheme
  # - do not have a fragment

  $self->_set_is_absolute((defined($self->scheme) && ! defined($self->fragment)) ? 1 : 0)
}

sub stringify {
    my ($self) = @_;
    #
    # Nothing else but the parse tree value (i.e. the URI_reference)
    #
    return $self->URI_reference
  }

sub clone {
  my ($self) = @_;

  return __PACKAGE__->new(#
                          # Our specific fields
                          #
                          is_absolute => $self->is_absolute,
                          #
                          # Role fields (there is no /external/ introspection API in Moo unless promotion to Moose AFAIK)
                          #
                          (map { $_ => $self->$_ } $self->URI_reference_fields),
                          (map { $_ => $self->$_ } $self->Scheme_fields),
                          (map { $_ => $self->$_ } $self->Authority_fields),
                          (map { $_ => $self->$_ } $self->Path_fields),
                          (map { $_ => $self->$_ } $self->Query_fields),
                          (map { $_ => $self->$_ } $self->Fragment_fields));
}

sub compare {
    my ($self1, $self2, $swap) = @_;

    return "$self1" cmp "$self2" # TO DO
}

with qw/MarpaX::ESLIF::URI::Role::URI_reference
        MarpaX::ESLIF::URI::Role::Scheme
        MarpaX::ESLIF::URI::Role::Authority
        MarpaX::ESLIF::URI::Role::Path
        MarpaX::ESLIF::URI::Role::Query
        MarpaX::ESLIF::URI::Role::Fragment/;

1;
