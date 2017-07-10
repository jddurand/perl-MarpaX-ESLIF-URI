package MarpaX::ESLIF::URI::Role;

# ABSTRACT: Generic role

# AUTHORITY

# VERSION

use Moo::Role;
use strictures 2;

#
# The three main entry points: URI, Reference and Absolute all have
# in common these three attributes
#
has 'authority' => (is => 'rw', trigger_ => _parse);
has 'path'      => (is => 'rw', trigger_ => _parse);
has 'query'     => (is => 'rw', trigger_ => _parse);
#
# All attributes have a trigger that requires a grammar and a parser
# Parse result will always be a hash whose keys are attributes to fill
#
requires 'grammar';
requires 'parse';
#
# Always parse also after construction (triggers are not called at build time)
#
sub BUILD {
    my ($self) = @_;

    $self->parse
}
#
# Parse result is always a hash whose keys will be the attributes to set
#
sub parse {
    my ($self) = @_;

    my $recognizerInterface = MarpaX::ESLIF::URI::Grammar::Recognizer->new($self->toString);
    my $valueInterface = MarpaX::ESLIF::URI::Grammar::Value->new();
    $self->grammar->parse();
    my $result = $valueInterface->getResult;

    foreach my $attribute (keys %{$result}) {
        $self->$attribute($result->{$attribute}) # Will croak if we made an error -;
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
