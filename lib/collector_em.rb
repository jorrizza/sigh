# The collector event machine.

require File.join(File.dirname(__FILE__), 'collector')
require 'eventmachine'

module Sigh
  class CollectorDaemon
    def self.run
      trap 'SIGINT' do
        exit!
      end

      begin
        EventMachine::run do
          # An event timer
          EventMachine::add_periodic_timer Sigh::INTERVAL, proc {
            # Make all collectors run in their own thread
            dir = Dir.new Sigh::COLLECTORS
            dir.each do |file|
              if file.end_with? '.rb'
                # Daemonize every collector
                collector_program = File.join(Sigh::PATH, 'sigh-collector')
                collector = file.sub /\.rb$/i, ''
                # The following throws EBADF in Daemons:
                # Process.detach fork { `#{collector_program} #{collector} 2>&1 > /dev/null` }
                # So this'll have to do.
                system "#{collector_program} #{collector} 2>&1 > /dev/null &"
              end
            end
            dir.close
          }
        end
      rescue
        $stderr.puts "ERROR: #{$!}"
      end
      
    end
  end
end
