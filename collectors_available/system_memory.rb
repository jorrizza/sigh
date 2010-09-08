# Sigh system collector collecting Linux memory usage

Sigh::Collector.collects do
  type 'system'
  name 'memory'
  unit 'kB'
  upper_bound lambda {
    value = nil
    
    File.read('/proc/meminfo').each do |line|
      value = line.split[1].to_f if line.start_with? 'MemTotal:'
    end
    
    value
  }

  measure do
    memtotal, memfree = nil, nil
    
    File.read('/proc/meminfo').each do |line|
      memfree = line.split[1].to_f if line.start_with? 'MemFree:'
      memtotal = line.split[1].to_f if line.start_with? 'MemTotal:'      
    end
    
    memtotal - memfree
  end
end
