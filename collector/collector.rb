# Sigh collector base class
# Aiming at some sort of DSL for the individual collectors

require 'socket'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sigh')

module Sigh
  class Collector
    def self.collects(&block)
      collector = Collector.new
      collector.host Socket.gethostname
      collector.instance_eval &block
    end

    # We can't use attr_accessor because it'll only
    # work outside of the instance. And we don't want
    # to be using @vars in the DSL, now do we?
    def host(h = nil)
      if h
        @host = h
      else
        @host
      end
    end
    def type(t = nil)
      if t
        @type = t
      else
        @type
      end
    end
    def name(n = nil)
      if n
        @name = n
      else
        @name
      end
    end
    def unit(u = nil)
      if u
        @unit = u
      else
        @unit
      end
    end
    def upper_bound(u = nil)
      if u
        @upper_bound = u
      else
        @upper_bound
      end
    end

    def measure(&block)
      @value = block.call

      # Check the collector
      unless @value.is_a? Float
        $stderr.puts "Your measure function doesn't product a Float!"
        exit
      end
      {
        :host => String,
        :type => String,
        :name => String,
        :unit => String,
        :upper_bound => Float
      }.each do |check, type|
        value = self.send check
        unless value
          $stderr.puts "You forgot to specify #{check.to_s}"
          exit
        end
        unless value.is_a? type
          $stderr.puts "#{check.to_s} is not a #{type.inspect}"
        end
      end

      # We support a dryrun to test the collector
      if ARGV[0] == '--dryrun'
        puts "#{@host}/#{@type}/#{@name} = #{@value} #{@unit} (max #{@upper_bound} #{@unit})"

      elsif ARGV[0] == '--monitor'
        # Monitor our plugin (when it's running in the background)
        m = Sigh::Measurement.new @host, @type, @name, @unit, @upper_bound

        # Clean up nicely
        trap 'SIGINT' do
          m.close
          exit!
        end

        loop do
          puts "#{m.last_time}\n#{@host}/#{@type}/#{@name} = #{m.latest_value} #{@unit} (max #{@upper_bound} #{@unit})"
          sleep Sigh::INTERVAL
        end
        
      else
        # For real now, we'll add a measurement
        m = Sigh::Measurement.new @host, @type, @name, @unit, @upper_bound
        m.store @value
        m.close
      end
    end
  end
end
