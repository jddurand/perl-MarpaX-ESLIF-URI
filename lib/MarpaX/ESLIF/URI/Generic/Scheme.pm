use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic::Scheme;

# ABSTRACT: URI Generic scheme as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use Moo;
use MarpaX::ESLIF::URI::Grammar;
use Types::Standard qw/Str Undef/;
use Unicode::CaseFold qw/fc/;
use overload
    '""' => 'stringify',
    'cmp' => 'compare',
    '<>' => 'compare',
    fallback => 1;

has 'input'    => (is => 'ro',  isa => Str|Undef, required => 1);
has 'encoding' => (is => 'ro',  isa => Str|Undef, required => 1);
has 'scheme'   => (is => 'rwp', isa => Str|Undef, default => sub {});

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    return {input => undef,    encoding => undef} if ! @args == 1;
    return {input => $args[0], encoding => undef} if @args == 1 && !ref $args[0];
    return $class->$orig(@args)
};

sub BUILD {
    my ($self, $args) = @_;

    my $input = $self->input;
    if (defined($input)) {
        $self->_set_scheme(MarpaX::ESLIF::URI::Grammar->parse(start => 'scheme',
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
