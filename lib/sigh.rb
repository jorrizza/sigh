# Sigh library
# It works with passing strings because most of it is
# called dynamically through a web GUI.

require 'time'
require 'rubygems'
require 'redis'
require File.join(File.dirname(__FILE__), '..', 'settings.rb')

module Sigh
  include SighSettings
  
  # The number of measurements stored for each graph
  # Default: 720 (every five seconds a measurement for an hour)
  RESOLUTION = 720
  INTERVAL = 5
  P = 'sigh' # Prefix
  S = ':'    # Separator
  
  # A measurement class to ease the creation and reading of
  # measurements in the Redis store.
  class Measurement
    def initialize(host, type, name, unit, upper_bound)
      @prefix = Sigh::P + Sigh::S + host + Sigh::S + type + Sigh::S + name

      @redis = Redis.new Sigh::REDIS
      begin
        @redis.ping
      rescue
        $stderr.puts "Sigh can't talk to Redis: #{$!}\n"
        exit 1
      end

      # We make sure the storage is what we expect it to be.
      # It makes the store and *_value functions a lot easier.
      ['hourly', 'daily', 'weekly', 'monthly', 'yearly'].each do |subkey|
        subkey_len = @redis.llen key(subkey)
        if subkey_len != Sigh::RESOLUTION
          @redis.del key(subkey)
          Sigh::RESOLUTION.times do
            @redis.rpush key(subkey), 0.0
          end
        end
      end

      # Set the unit and upper bound
      @redis.set key('unit'), unit
      @redis.set key('upper_bound'), upper_bound
    end

    # Unused, but may come in handy.
    # Clean up our measurement.
    def cleanup
      ['hourly', 'daily', 'weekly', 'monthly', 'yearly', 'i', 'last_time', 'upper_bound', 'unit'].each do |subkey|
        @redis.del key(subkey)
      end
    end

    def store(value)
      # Last access time, used in GUI.
      @redis.set key('last_time'), Time.now.to_s
      
      # The incrementer, used by the following code.
      i = @redis.incr key('i')

      # Update hourly values.
      @redis.lpop key('hourly')
      @redis.rpush key('hourly'), value

      # Update daily values.
      if i.modulo(24) == 0
        @redis.lpop key('daily')
        value = 0.0
        @redis.lrange(key('hourly'), -1, -24).each do |v|
          value += v.to_f
        end
        value /= 24
        @redis.rpush key('daily'), value
      end

      # Update weekly values.
      if i.modulo(168) == 0
        @redis.lpop key('weekly')
        value = 0.0
        @redis.lrange(key('daily'), -1, -7).each do |v|
          value += v.to_f
        end
        value /= 7
        @redis.rpush key('weekly'), value
      end

      # Update monthly values.
      if i.modulo(720) == 0 # 30 days
        @redis.lpop key('monthly')
        value = 0.0
        @redis.lrange(key('daily'), -1, -30).each do |v|
          value += v.to_f
        end
        value /= 30
        @redis.rpush key('monthly'), value
      end

      # Update yearly values.
      if i.modulo(8640) == 0 # 360 days (works better with modulo)
        @redis.lpop key('yearly')
        value = 0.0
        @redis.lrange(key('monthly'), -1, -12).each do |v|
          value += v.to_f
        end
        value /= 12
        @redis.rpush key('yearly'), value
      end
    end

    def last_time
      last_time = @redis.get(key('last_time'))
      return Time.parse last_time if last_time
      Time.now # Probably...
    end

    def latest_value
      @redis.lindex(key('hourly'), -1).to_f
    end

    def hourly_values
      @redis.lrange(key('hourly'), 0, -1).map do |v|
        v.to_f
      end
    end

    def daily_values
      @redis.lrange(key('daily'), 0, -1).map do |v|
        v.to_f
      end
    end

    def weekly_values
      @redis.lrange(key('weekly'), 0, -1).map do |v|
        v.to_f
      end
    end

    def monthly_values
      @redis.lrange(key('monthly'), 0, -1).map do |v|
        v.to_f
      end
    end

    def yearly_values
      @redis.lrange(key('yearly'), 0, -1).map do |v|
        v.to_f
      end
    end

    # Be nice to Redis.
    def close
      @redis.quit
    end

    private

    # Simple helper function. Reduces strain on yours truly.
    def key(k)
      @prefix + Sigh::S + k
    end
  end

  # Lists the hosts that have data in the Sigh store.
  class HostList
    def initialize
      @redis = Redis.new Sigh::REDIS
      begin
        @redis.ping
      rescue
        $stderr.puts "Sigh can't talk to Redis: #{$!}\n"
        exit 1
      end
    end
    
    def each
      hosts = Array.new
      @redis.keys(Sigh::P + Sigh::S + '*').each do |key|
        host = key.split(Sigh::S)[1]
        hosts << host unless hosts.include? host
      end

      hosts.each do |h|
        yield h
      end
    end
  end

  # A single host.
  class Host
    def initialize(name)
      @redis = Redis.new Sigh::REDIS
      begin
        @redis.ping
      rescue
        $stderr.puts "Sigh can't talk to Redis: #{$!}\n"
        exit 1
      end

      @name = name
    end

    # Returns the collectors the Sigh store has data from.
    def collectors
      coll = Hash.new

      @redis.keys(Sigh::P + Sigh::S + @name + Sigh::S + '*' + Sigh::S + 'upper_bound').each do |key|
        collector, name = key.split(Sigh::S)[2], key.split(Sigh::S)[3]
        unit = @redis.get(Sigh::P + Sigh::S + @name + Sigh::S + collector + Sigh::S + name + Sigh::S + 'unit')
        upper_bound = @redis.get(Sigh::P + Sigh::S + @name + Sigh::S + collector + Sigh::S + name + Sigh::S + 'upper_bound')
        coll[collector] = Array.new unless coll[collector]
        coll[collector] << {
          :name => name,
          :upper_bound => upper_bound.to_f,
          :unit => unit
        }
      end

      coll
    end
  end
end
