package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo;
use strictures 2;
use Carp qw/croak/;
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
  #
  # No need to reparse when we clone - we know all the attributes
  #
  return __PACKAGE__->new(#
                          # Role fields (there is no /external/ introspection API in Moo unless promotion to Moose AFAIK)
                          #
                          (map { $_ => $self->$_ } $self->URI_reference_fields),
                          (map { $_ => $self->$_ } $self->Scheme_fields),
                          (map { $_ => $self->$_ } $self->Authority_fields),
                          (map { $_ => $self->$_ } $self->Path_fields),
                          (map { $_ => $self->$_ } $self->Query_fields),
                          (map { $_ => $self->$_ } $self->Fragment_fields));
}

sub base {
  my ($self) = @_;

  if ($self->is_absolute) {
    #
    # We are already a base URI
    #
    return $self->clone
  } else {
    #
    # We need the scheme
    #
    croak "Cannot derive a base URI from $self: there is no scheme" unless defined $self->scheme;
    #
    # Here per def there is a fragment
    #
    my $quote_fragment = quotemeta($self->fragment);
    my $new_string = "$self";
    $new_string =~ s/#$quote_fragment$//;
    #
    # In theory, I could have done like clone by setting explicitly URI_reference to $new_string and fragments to undef
    #
    # return __PACKAGE__->new(#
    #                         # Role fields (there is no /external/ introspection API in Moo unless promotion to Moose AFAIK)
    #                         #
    #                         URI_reference => $new_string,
    #                         (map { $_ => $self->$_ } $self->Scheme_fields),
    #                         (map { $_ => $self->$_ } $self->Authority_fields),
    #                         (map { $_ => $self->$_ } $self->Path_fields),
    #                         (map { $_ => $self->$_ } $self->Query_fields),
    #                         (map { $_ => undef } $self->Fragment_fields));
    return __PACKAGE__->new($new_string)
  }
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
