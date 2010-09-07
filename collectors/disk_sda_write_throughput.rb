# Sigh disk collector collecting Linux disk write throughput

Sigh::Collector.collects do
  type 'disk'
  name 'sda_write_throughput'
  unit 'kB/s'
  upper_bound 0.0 # Configure a sane value here. Can't tell what your hardware limits are.

  measure do
    disk = 'sda'
    first, second = nil, nil

    2.times do
      unless first
        first = File.read("/sys/block/#{disk}/stat").strip.split[6].to_f * 0.5
        sleep 1
      else
        second = File.read("/sys/block/#{disk}/stat").strip.split[6].to_f * 0.5
      end
    end

    second - first
  end
end
