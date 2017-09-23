use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::URI::_generic::RecognizerInterface;

# VERSION

# AUTHORITY

# ABSTRACT: MarpaX::ESLIF's URI Recognizer Interface

#
# This class is very internal and should not harm Pod coverage test
#

=for Pod::Coverage *EVERYTHING*

=cut

#
# Optimized constructor
#
sub new { bless \$_[1], $_[0] }
#
# Recognizer Interface required methods
#
sub read                   {          1 } # First read callback will be ok
sub isEof                  {          1 } # ../. and we will say this is EOF
sub isCharacterStream      {          1 } # MarpaX::ESLIF will validate the input
sub encoding               {          } # Let MarpaX::ESLIF guess
sub data                   { "${$_[0]}" } # Forced stringified input
sub isWithDisableThreshold {          0 } # Disable threshold warning ?
sub isWithExhaustion       {          0 } # Exhaustion event ?
sub isWithNewline          {          0 } # Newline count ?
sub isWithTrack            {          0 } # Absolute position tracking ?

1;
