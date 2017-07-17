#!env perl

use strict;
use diagnostics;
use IO::Handle;
use Log::Log4perl qw/:easy/;
use Log::Any::Adapter;
use Log::Any qw/$log/;
use MarpaX::ESLIF::URI;
use Data::Scan::Printer;

autoflush STDOUT 1;
autoflush STDERR 1;

#
# Init log
#
our $defaultLog4perlConf = '
        log4perl.rootLogger              = TRACE, Screen
        log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr  = 0
        log4perl.appender.Screen.layout  = PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
        ';
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');

while (@ARGV) {
  print "From argument...:\n";
  my $uri;
  #eval {
      $uri = MarpaX::ESLIF::URI->new(shift @ARGV);
      local %Data::Scan::Printer::Option = (with_ansicolor => 0);
      dspp($uri);
      print "\n";
      print "Stringification: $uri\n";
  #};
  #print "$@" if $@;

  print "\nFrom clone...:\n";
  my $clone;
  {
      $clone = $uri->clone;
      local %Data::Scan::Printer::Option = (with_ansicolor => 0);
      dspp($clone);
      print "\n";
      print "Stringification: $clone\n";
  };
  print "$@" if $@;

  print "\nFrom abs...:\n";
  eval {
    my $abs = $uri->abs;
    local %Data::Scan::Printer::Option = (with_ansicolor => 0);
    dspp($abs);
    print "\n";
    print "Stringification: $abs\n";
  };
  print "$@" if $@;
}

