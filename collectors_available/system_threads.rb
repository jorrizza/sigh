# Sigh system collector collecting Linux active threads

Sigh::Collector.collects do
  type 'system'
  name 'threads'
  unit 'Threads'
  upper_bound 0.0 # This is system specific and hardly ever an issue

  measure do
    amount = 0.0
    
    Dir.foreach('/proc') do |file|
      # During the loop, the file might vanish
      # So we need to silently ignore read errors
      if file =~ /[0-9]+/
        begin
          File.read('/proc/' + file + '/status').each do |line|
            if line.start_with? 'Threads:'
              amount += line.split[1].to_f
            end
          end
        rescue
          # Nothing :)
        end
      end
    end

    amount
  end
end
