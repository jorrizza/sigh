# Sigh system collector collecting Linux active processes

Sigh::Collector.collects do
  type 'system'
  name 'processes'
  unit 'Processes'
  upper_bound 0.0 # This is system specific and hardly ever an issue

  measure do
    amount = 0.0
    
    Dir.foreach('/proc') do |file|
      if file =~ /[0-9]+/
        amount += 1.0
      end
    end

    amount
  end
end
