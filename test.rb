require 'lib/sigh'

m = Sigh::Measurement.new('zitvlak', 'network', 'eth0_traffic', 'Mbit/s', 1100.0)
m.close
m = Sigh::Measurement.new('zitvlak', 'network', 'eth1_traffic', 'Mbit/s', 1100.0)
p m.hourly_values
p m.latest_value
p m.last_time
m.close

hostlist = Sigh::HostList.new
hostlist.each do |h|
  puts h
  host = Sigh::Host.new h
  p host.collectors
end
