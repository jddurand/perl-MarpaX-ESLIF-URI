use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic;

# ABSTRACT: URI Generic syntax as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo;
use MarpaX::ESLIF::URI::Generic::Scheme;
use Types::Standard qw/Str Undef Bool HashRef InstanceOf/;

has 'input'    => (is => 'ro',  isa => Str|Undef, required => 1);
has 'encoding' => (is => 'ro',  isa => Str|Undef, required => 1);
has 'absolute' => (is => 'ro',  isa => Bool,      required => 1);
has 'scheme'   => (is => 'rwp', isa => InstanceOf['MarpaX::ESLIF::URI::Generic::Scheme'], default => sub { MarpaX::ESLIF::URI::Generic::Scheme->new() });
has 'parse'    => (is => 'rwp', isa => HashRef, default => sub { {} });

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    return {input => undef,    encoding => undef, absolute => 0} if ! @args == 1;
    return {input => $args[0], encoding => undef, absolute => 0} if @args == 1 && !ref $args[0];
    return $class->$orig(@args)
};

sub BUILD {
    my ($self, $args) = @_;

    my $input = $self->input;
    if (defined($input)) {
        my $absolute = $self->absolute;
        $self->_set_parse(MarpaX::ESLIF::URI::Grammar->parse(start => $absolute ? 'absolute URI' :'URI reference',
                                                             input => $self->input,
                                                             encoding => $self->encoding,
                                                             logger => $self->_logger,
                                                             decode => 1));
    }
}
sub stringify {
    my ($self) = @_;

    return $self->has_predicate ? $self->scheme : ''
}

sub compare {
    my ($self1, $self2, $swap) = @_;

    ($self1, $self2) = ($self2, $self1) if $swap;

    return $self1->normalize cmp $self2->normalize
}

sub normalize {
    my ($self) = @_;

    my $string = "$self";          # Stringification

    #
    # Schemes are care insensitive
    #
    my $normalized = fc($string);

    #
    # And that's all
    #
    return $normalized
}

with qw/MooX::Role::Logger/;

1;
