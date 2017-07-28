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
   # Adapted from https://github.com/serut/vieassociative/blob/master/vendor/lusitanian/oauth/tests/Unit/Common/Http/Uri/UriTest.php
   #
   "http://example.com" => {
                              scheme    => { origin => "http",                                 decoded => "http",                                 normalized => "http" },
                              host      => { origin => "example.com",                          decoded => "example.com",                          normalized => "example.com" },
                              path      => { origin => "",                                     decoded => "",                                     normalized => "/" },
                             },
   "http://peehaa\@example.com" => {
                              scheme    => { origin => "http",                                 decoded => "http",                                 normalized => "http" },
                              host      => { origin => "example.com",                          decoded => "example.com",                          normalized => "example.com" },
                              path      => { origin => "",                                     decoded => "",                                     normalized => "/" },
                              userinfo  => { origin => "peehaa",                               decoded => "peehaa",                               normalized => "peehaa" },
                             },
   "http://peehaa:pass\@example.com" => {
                              scheme    => { origin => "http",                                 decoded => "http",                                 normalized => "http" },
                              host      => { origin => "example.com",                          decoded => "example.com",                          normalized => "example.com" },
                              path      => { origin => "",                                     decoded => "",                                     normalized => "/" },
                              userinfo  => { origin => "peehaa:pass",                          decoded => "peehaa:pass",                          normalized => "peehaa:pass" },
                             },
  );

foreach my $origin (sort keys %DATA) {
  my $uri = MarpaX::ESLIF::URI->new($origin);
  isa_ok($uri, 'MarpaX::ESLIF::URI::http', "\$uri = MarpaX::ESLIF::URI->new('$origin')");
  my $methods = $DATA{$uri};
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
