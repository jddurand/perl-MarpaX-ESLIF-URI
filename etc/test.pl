#!env perl

use strict;
use diagnostics;
use IO::Handle;
use Log::Log4perl qw/:easy/;
use Log::Any::Adapter;
use Log::Any qw/$log/;
use MarpaX::ESLIF::URI;
use Data::Scan::Printer;
use Devel::Peek;

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

local %Data::Scan::Printer::Option = (with_ansicolor => 0);

while (@ARGV) {
  print "From argument...:\n";
  my $uri;
  eval {
      $uri = MarpaX::ESLIF::URI->new(shift @ARGV);
      dspp($uri);
      print "\n";
      print "Stringification: $uri\n";
      Dump("$uri");
  };
  print "$@" if $@;

  print "\nFrom clone...:\n";
  eval {
    my $clone = $uri->clone;
    dspp($clone);
    print "\n";
    print "Stringification: $clone\n";
  };
  print "$@" if $@;

  print "\nFrom base...:\n";
  eval {
    my $base = $uri->base;
    dspp($base);
    print "\n";
    print "Stringification: $base\n";
  };
  print "$@" if $@;

}

