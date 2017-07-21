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

my $format  = '%-21s : %s';
my @methods = qw/string scheme authority host ip ipv4 ipv6 ipvx zone port path segments query fragment opaque drive/;
my @_methods = qw/_string _scheme _authority _host _ip _ipv4 _ipv6 _ipvx _zone _port _path _segments _query _fragment _opaque _drive/;

while (@ARGV) {

  my $self;
  $log->info('----------------------------------------');
  $log->info('Argument test');
  $log->info('----------------------------------------');
  eval {
      $self = MarpaX::ESLIF::URI->new(shift @ARGV);
      dspp($self); print "\n";
      $log->infof($format, 'Type', ref($self));
      foreach (@methods, @_methods) {
          next unless $self->can($_);
          $log->infof($format, $_, $self->$_);
      }
  };
  $log->errorf('%s', $@) if $@;

  $log->info('----------------------------------------');
  $log->info('Base test');
  $log->info('----------------------------------------');
  my $base;
  eval {
      $base = $self->base;
      # dspp($base); print "\n";
      $log->infof($format, 'Type', ref($base));
      foreach (@methods, @_methods) {
          next unless $base->can($_);
          $log->infof($format, $_, $base->$_);
      }
  };
  $log->errorf('%s', $@) if $@;

  $log->info('----------------------------------------');
  $log->info('eq test');
  $log->info('----------------------------------------');
  eval {
      my $eq = $self eq $base;
      $log->infof($format, '$self eq $base', $eq);
  };
  $log->errorf('%s', $@) if $@;
}

