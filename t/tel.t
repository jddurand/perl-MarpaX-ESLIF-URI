#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Differences;
use Data::Dumper::OneLine qw/Dumper/;

BEGIN {
    use_ok( 'MarpaX::ESLIF::URI' ) || print "Bail out!\n";
}

my %DATA =
  (
   #
   # Adapted from http://www.scottseverance.us/mailto.html
   #
   "Tel:+358-9-123-45678" => {
       scheme         => {              origin => "Tel",              decoded => "Tel",              normalized => "tel" },
       number         => {              origin => "+358-9-123-45678", decoded => "+358-9-123-45678", normalized => "+358912345678"},
   },
   "Tel:45678;phone-context=Example.Com" => {
       scheme         => {              origin => "Tel",              decoded => "Tel",              normalized => "tel" },
       number         => {              origin => "45678",            decoded => "45678",            normalized => "45678"},
       phone_context  => {              origin => "Example.Com",      decoded => "Example.Com",      normalized => "Example.Com"},
       parameters     =>
       {
           origin     =>   [ { key => "phone-context", value => "Example.Com" } ],
           decoded    =>   [ { key => "phone-context", value => "Example.Com" } ],
           normalized =>   [ { key => "phone-context", value => "Example.Com" } ]
       }
   },
   "tel:+1-800-123-4567;cic=+1-6789" => {
       scheme         => {              origin => "tel",              decoded => "tel",              normalized => "tel" },
       number         => {              origin => "+1-800-123-4567",  decoded => "+1-800-123-4567",  normalized => "+18001234567"},
       cic            => {              origin => "+1-6789",          decoded => "+1-6789",          normalized => "+16789"},
       parameters     =>
       {
           origin     =>   [ { key => "cic", value => "+1-6789" } ],
           decoded    =>   [ { key => "cic", value => "+1-6789" } ],
           normalized =>   [ { key => "cic", value => "+16789" } ]
       }
   },
   "tel:+1-202-533-1234;npdi;rn=+1-202-544-0000" => {
       scheme         => {              origin => "tel",              decoded => "tel",              normalized => "tel" },
       number         => {              origin => "+1-202-533-1234",  decoded => "+1-202-533-1234",  normalized => "+12025331234"},
       rn             => {              origin => "+1-202-544-0000",  decoded => "+1-202-544-0000",  normalized => "+12025440000"},
       parameters     =>
       {
           origin     =>   [ { key => 'npdi', value => undef }, { key => "rn", value => "+1-202-544-0000" } ],
           decoded    =>   [ { key => 'npdi', value => undef }, { key => "rn", value => "+1-202-544-0000" } ],
           normalized =>   [ { key => 'npdi', value => undef }, { key => "rn", value => "+12025440000" } ]
       }
   },
   "tel:+1-202-533-6789;npdi" => {
       scheme         => {              origin => "tel",              decoded => "tel",              normalized => "tel" },
       number         => {              origin => "+1-202-533-6789",  decoded => "+1-202-533-6789",  normalized => "+12025336789"},
       parameters     =>
       {
           origin     =>   [ { key => 'npdi', value => undef } ],
           decoded    =>   [ { key => 'npdi', value => undef } ],
           normalized =>   [ { key => 'npdi', value => undef } ]
       }
   }
  );

foreach my $origin (sort keys %DATA) {
  my $uri = MarpaX::ESLIF::URI->new($origin);
  isa_ok($uri, 'MarpaX::ESLIF::URI::tel', "\$uri = MarpaX::ESLIF::URI->new('$origin')");
  my $methods = $DATA{$origin};
  foreach my $method (sort keys %{$methods}) {
    foreach my $type (sort keys %{$methods->{$method}}) {
      my $got = $uri->$method($type);
      my $expected = $methods->{$method}->{$type};
      my $test_name = "\$uri->$method('$type')";
      if (ref($expected)) {
        eq_or_diff($got, $expected, "$test_name is " . (defined($expected) ? Dumper($expected) : "undef"));
      } else {
        is($got, $expected, "$test_name is " . (defined($expected) ? "'$expected'" : "undef"));
      }
    }
  }
}

done_testing();
