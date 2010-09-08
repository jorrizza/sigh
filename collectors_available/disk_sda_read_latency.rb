# Sigh disk collector collecting Linux disk read latency

Sigh::Collector.collects do
  type 'disk'
  name 'sda_read_latency'
  unit 'ms'
  upper_bound 0.0 # Configure a sane value here. Can't tell what your hardware limits are.

  measure do
    disk = 'sda'
    first_io, second_io = nil, nil
    first_ticks, second_ticks = nil, nil

    2.times do
      unless first_io
        str = File.read("/sys/block/#{disk}/stat")
        first_io = str.strip.split[0].to_f
        first_ticks = str.strip.split[3].to_f
        sleep 1
      else
        str = File.read("/sys/block/#{disk}/stat")
        second_io = str.strip.split[0].to_f
        second_ticks = str.strip.split[3].to_f
      end
    end

    if (second_io - first_io) > 0
      (second_ticks - first_ticks) / (second_io - first_io)
    else
      0.00
    end
  end
end
