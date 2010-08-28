# Sigh library

require 'rubygems'
require 'redis'
require File.dirname(__FILE__) + '/../settings'

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
    def initialize(host, type, name)
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
    end

    def cleanup
      ['hourly', 'daily', 'weekly', 'monthly', 'yearly', 'i'].each do |subkey|
        @redis.del key(subkey)
      end
    end

    def store(value)
      # The time
      @redis.set key('lasttime'), Time.now.to_s
      
      # The incrementer
      i = @redis.incr key('i')

      # Update hourly values
      @redis.lpop key('hourly')
      @redis.rpush key('hourly'), value

      # Update daily values
      if i.modulo(24) == 0
        @redis.lpop key('daily')
        value = 0.0
        hourly_values.each do |v|
          value += v.to_f
        end
        value /= Sigh::RESOLUTION
        @redis.rpush key('daily'), value
      end

      # Update weekly values
      if i.modulo(168) == 0
        @redis.lpop key('weekly')
        value = 0.0
        daily_values.each do |v|
          value += v.to_f
        end
        value /= Sigh::RESOLUTION
        @redis.rpush key('weekly'), value
      end

      # Update monthly values
      if i.modulo(720) == 0 # 30 days
        @redis.lpop key('monthly')
        value = 0.0
        weekly_values.each do |v|
          value += v.to_f
        end
        value /= Sigh::RESOLUTION
        @redis.rpush key('monthly'), value
      end

      # Update yearly values
      if i.modulo(8760) == 0 # 365 days
        @redis.lpop key('yearly')
        value = 0.0
        monthly_values.each do |v|
          value += v.to_f
        end
        value /= Sigh::RESOLUTION
        @redis.rpush key('yearly'), value
      end
    end

    def latest_value
      @redis.lindex key('hourly'), -1
    end

    def hourly_values
      @redis.lrange key('hourly'), 0, -1
    end

    def daily_values
      @redis.lrange key('daily'), 0, -1
    end

    def weekly_values
      @redis.lrange key('weekly'), 0, -1
    end

    def monthly_values
      @redis.lrange key('monthly'), 0, -1
    end

    def yearly_values
      @redis.lrange key('yearly'), 0, -1
    end

    def close
      @redis.quit
    end

    private

    def key(k)
      @prefix + Sigh::S + k
    end
  end

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
        host = key.split(':')[1]
        hosts << host unless hosts.include? host
      end

      hosts.each do |h|
        yield h
      end
    end
  end

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

    def collectors
      coll = Hash.new

      @redis.keys(Sigh::P + Sigh::S + @name + Sigh::S + '*').each do |key|
        collector, name = key.split(':')[2], key.split(':')[3]
        if coll[collector]
          coll[collector] << name unless coll[collector].include? name
        else
          coll[collector] = [name]
        end
      end

      coll
    end
  end
end
