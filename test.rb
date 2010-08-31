require 'collector/collector'

#m = Sigh::Measurement.new('zitvlak', 'network', 'eth0_traffic', 'Mbit/s', 1100.0)
#m.store 112.0
#m.close

Sigh::Collector.collects do
  type 'system'
  name 'load'
  unit 'processes'
  upper_bound 8.00

  measure do
    File.read('/proc/loadavg').split[0].to_f
  end
end
