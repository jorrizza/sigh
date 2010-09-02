# Sigh system collector collecting Linux system load

Sigh::Collector.collects do
  type 'system'
  name 'load'
  unit 'processes'
  upper_bound lambda {
    # Simple rule of thumb: 2x number of processors
    # Warning: this is situation and configuration dependant
    # We should parse /sys/devices/system/cpu/online, but
    # /proc/cpuinfo is easier.
    nr_cpus = 0.0

    File.read('/proc/cpuinfo').each_line do |line|
      nr_cpus += 1 if line.start_with? "processor\t"
    end

    nr_cpus * 2
  }

  measure do
    File.read('/proc/loadavg').split[0].to_f
  end
end
