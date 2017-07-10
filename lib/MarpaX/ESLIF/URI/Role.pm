package MarpaX::ESLIF::URI::Role;

# ABSTRACT: Generic role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

use Carp qw/croak/;
use MarpaX::ESLIF::URI::Grammar;

requires 'input';
requires 'encoding';
requires 'scheme';
requires 'authority';
requires 'path';
requires 'query';
requires 'fragment';
requires 'start';    # Starting point in the grammar

around BUILDARGS => sub {
  my ($orig, $class, @args) = @_;

  return { input => $args[0] } if @args == 1 && !ref $args[0];

  return $class->$orig(@args);
};

sub BUILD {
  my ($self, $args) = @_;

  my $parseResult = MarpaX::ESLIF::URI::Grammar->parse(
                                                       start    => $self->start,
                                                       input    => $args->{input},
                                                       encoding => $args->{encoding},
                                                       logger   => $self->_logger
                                                      );
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

with qw/MooX::Role::Logger/;

1;
