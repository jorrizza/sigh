# Sigh system collector collecting Linux swap usage

Sigh::Collector.collects do
  type 'system'
  name 'swap'
  unit 'kB'
  upper_bound lambda {
    value = nil
    
    File.read('/proc/meminfo').each_line do |line|
      value = line.split[1].to_f if line.start_with? 'SwapTotal:'
    end
    
    value
  }

  measure do
    swaptotal, swapfree = nil, nil
    
    File.read('/proc/meminfo').each_line do |line|
      swapfree = line.split[1].to_f if line.start_with? 'SwapFree:'
      swaptotal = line.split[1].to_f if line.start_with? 'SwapTotal:'      
    end
    
    swaptotal - swapfree
  end
end
