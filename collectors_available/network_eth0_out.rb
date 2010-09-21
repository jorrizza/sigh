# Sigh network collector collecting Linux interface output traffic

Sigh::Collector.collects do
  type 'network'
  name 'eth0_out'
  unit 'kB/s'
  upper_bound 0.0 # Doesn't really make sense on a network interface

  measure do
    first, second = nil, nil

    2.times do
      File.read('/proc/net/dev').each_line do |line|
        line.strip!
        if line.start_with? 'eth0'
          unless first
            first = line.split[8].to_f
            sleep 1
          else
            second = line.split[8].to_f
          end
        end
      end
    end

    (second - first) / 1024.0
  end
end
