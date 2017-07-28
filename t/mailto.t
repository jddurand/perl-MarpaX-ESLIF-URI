#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Differences;

BEGIN {
    use_ok( 'MarpaX::ESLIF::URI' ) || print "Bail out!\n";
}

my %DATA =
  (
   #
   # Adapted from http://www.scottseverance.us/mailto.html
   #
   "mailto:bogus\@email.com" => {
       scheme    => { origin => "mailto",                               decoded => "mailto",                               normalized => "mailto" },
   },
   "mailto:bogus\@email.com?subject=test" => {
       scheme    => { origin => "mailto",                               decoded => "mailto",                               normalized => "mailto" },
   },
   "mailto:bogus\@email.com?subject=test%20subject&body=This%20is%20the%20body%20of%20this%20message." => {
       scheme    => { origin => "mailto",                               decoded => "mailto",                               normalized => "mailto" },
   },
   "mailto:bogus\@email.com?cc=bogus2\@snail-mail.com&bcc=fake\@spam.com" => {
       scheme    => { origin => "mailto",                               decoded => "mailto",                               normalized => "mailto" },
   },
  );

foreach my $origin (sort keys %DATA) {
  my $uri = MarpaX::ESLIF::URI->new($origin);
  isa_ok($uri, 'MarpaX::ESLIF::URI::mailto', "\$uri = MarpaX::ESLIF::URI->new('$origin')");
  my $methods = $DATA{$origin};
  foreach my $method (sort keys %{$methods}) {
    foreach my $type (sort keys %{$methods->{$method}}) {
      my $got = $uri->$method($type);
      my $expected = $methods->{$method}->{$type};
      my $test_name = "\$uri->$method('$type')";
      if (ref($expected)) {
        eq_or_diff($got, $expected, "$test_name is " . (defined($expected) ? (ref($expected) eq 'ARRAY' ? "[" . join(", ", map { "'$_'" } @{$expected}) . "]" : "$expected") : "undef"));
      } else {
        is($got, $expected, "$test_name is " . (defined($expected) ? "'$expected'" : "undef"));
      }
    }
  }
}

done_testing();
