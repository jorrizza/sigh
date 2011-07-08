# The collector event machine.

require File.join(File.dirname(__FILE__), 'collector')
require 'eventmachine'

module Sigh
  class CollectorDaemon
    def self.run
      trap 'SIGINT' do
        exit!
      end

      # First build our Thread pool
      threads = Hash.new
      dir = Dir.new Sigh::COLLECTORS
        dir.each do |file|
        if file.end_with? '.rb'
          threads[file.sub(/\.rb$/i, '')] = Thread.new(file) do |collector|
            loop do
              # Run the collector.
              begin
                load File.join(Sigh::COLLECTORS, collector)
              rescue
                $stderr.puts "#{collector}: #{$!}"
                Thread.exit
              else
                # And go to sleep (until EM wakes us up).
                Thread.stop
              end
            end
          end
        end
      end
      dir.close
      
      # Using eventmachine, make every thread wake up once every INTERVAL.
      EventMachine::run do
        EventMachine::add_periodic_timer Sigh::INTERVAL, proc {
          # Wake up! Or if things have gone report about it.
          threads.each do |collector, thread|
            # Skip dead threads (see below).
            next if thread.nil?
            
            case thread.status
            when 'run'
              # Do nothing. Collector is still running. Fixes #2.
              $stderr.puts "Collector #{collector} is lagging!"
            when 'sleep'
              # Waiting for me or I/O. Doesn't matter which. Wake it up!
              # Weirdly enough, Ruby's #wakeup doesn't actually kick
              # the scheduler.
              thread.run
            when false # Goshdarnet!
              $stderr.puts "Collector #{collector} has exited!"
              thread.join
              threads[collector] = nil
            end
          end
        }
      end
    end
  end
end
