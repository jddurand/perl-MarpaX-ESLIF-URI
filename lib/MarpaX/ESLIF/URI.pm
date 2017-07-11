use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI;

# ABSTRACT: URI decoder as per RFC3986/RFC6874

# AUTHORITY

# VERSION

use MarpaX::ESLIF::URI::Grammar;

#
# Default is <URI reference>
#
sub new {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'URI reference', input => $args[0]), __PACKAGE__)
  } else {
    my %args = (@args);
    my $start = delete $args{start} // 'URI reference';
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => $start, %args), __PACKAGE__)
  }
}

#
# Though one can build an explicit <absolute URI>
#
sub new_abs {
  my ($class, @args) = @_;

  if ($#args == 0) {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'absolute URI', input => $args[0]), __PACKAGE__)
  } else {
    return bless(MarpaX::ESLIF::URI::Grammar->parse(start => 'absolute URI', @args))
  }
}

#
# Stringification
#
sub toString {
    my ($self) = @_;

    $self->{utf8} # UTF-8 parsed tree value
}

#
# Decode the percent-encoded characters
#
sub decode {
    my ($self) = @_;

    return __PACKAGE__->new(start => $self->{start},
                            input => $self->{utf8},       # No need to re-enter character encoding/decoding phase
                            encoding => 'UTF-8',
                            decode => 1)
}

sub _remove_dot_segments {
    my ($self) = @_;

    my @old_segments = @{$self->{segments}};
    my @new_segments = ();

    while (@old_segments) {
        my $old_segment = shift @old_segments;

        if ($old_segment eq '.') {
            next if @old_segments
        } elsif ($old_segment eq '..') {
            shift(@new_segments);
            next
        }
        push(@new_segments, $old_segment)
    }

    $self->{segments} = \@new_segments
}

1;
