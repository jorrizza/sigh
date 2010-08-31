require 'lib/collector'

Sigh::Collector.collects do
  type 'system'
  name 'load'
  unit 'processes'
  upper_bound 8.00

  measure do
    File.read('/proc/loadavg').split[0].to_f
  end
end
