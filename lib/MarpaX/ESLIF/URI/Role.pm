package MarpaX::ESLIF::URI::Role;

# ABSTRACT: Generic role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

use Carp qw/croak/;
use MarpaX::ESLIF::URI::Grammar;

has scheme    => (is => 'rwp');
has authority => (is => 'rwp');
has path      => (is => 'rwp');
has query     => (is => 'rwp');
has fragment  => (is => 'rwp');

sub BUILD {
  my ($self, $args) = @_;

  my $parse = MarpaX::ESLIF::URI::Grammar->parse(
                                                 start    => delete $args->{start},
                                                 input    => delete $args->{input},
                                                 encoding => delete $args->{encoding},
                                                 logger   => $self->_logger
                                                );

  foreach (keys %{$parse}) {
    my $setter = "_set_$_";
    $self->$setter($parse->{$_})
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

with qw/MooX::Role::Logger/;

1;
