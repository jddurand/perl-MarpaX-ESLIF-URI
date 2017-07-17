use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::Generic::RecognizerInterface;

sub new {
    my ($class, $uri) = @_;

    bless \$uri, $class
}

#
# Recognizer Interface required methods
#
sub read                   {        1 } # First read callback will be ok
sub isEof                  {        1 } # ../. and we will say this is EOF
sub isCharacterStream      {        1 } # MarpaX::ESLIF will validate the input
sub encoding               {          } # Let MarpaX::ESLIF guess
sub data                   { ${$_[0]} } # Input
sub isWithDisableThreshold {        0 } # Disable threshold warning ?
sub isWithExhaustion       {        0 } # Exhaustion event ?
sub isWithNewline          {        0 } # Newline count ?
sub isWithTrack            {        0 } # Absolute position tracking ?

1;
