spec = Gem::Specification.new do |s|
  s.name = 'sigh'
  s.version = '0.1'
  s.summary = 'System Monitoring Application'
  s.description = 'An extensible system monitoring application using Redis and Sinatra'
  s.author = 'Joris van Rooij'
  s.email = 'jorrizza@jrrzz.net'
  s.homepage = 'https://github.com/jorrizza/sigh'

  s.bindir = 'bin'
  s.executables = %w{sigh-web sigh-collector sigh-collectord}

  s.files = %w{
  bin
  bin/sigh-web
  bin/sigh-collector
  bin/sigh-collectord
  lib
  lib/sigh.rb
  lib/sigh/collector.rb
  lib/sigh/collector_em.rb
  web
  web/**
  web/static/**
  web/static/img/**
  web/static/css/**
  web/static/js/**
  settings.yml
  collectors_enabled
  collectors_enabled/.dir
  collectors_available
  collectors_available/**
  }.map { |glob| Dir.glob glob }.flatten

  s.add_dependency 'sinatra'
  s.add_dependency 'redis'
  s.add_dependency 'daemons'
  s.add_dependency 'eventmachine'
end
