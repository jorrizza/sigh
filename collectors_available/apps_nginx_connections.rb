# Sigh apps collector collecting NGINX connections
# You'll need to add the following config in your server config, in
# a sever {} block listening on localhost.
# location /nginx_status {
#   stub_status on;
#   access_log off;
#   allow 127.0.0.1;
#   deny all;
# }

require 'net/http'

Sigh::Collector.collects do
  type 'apps'
  name 'nginx_connections'
  unit 'Conn/s'
  upper_bound 0.0 # It can do over 9000 in theory, so ehm...

  measure do
    first, second = nil, nil

    2.times do
      begin
        Net::HTTP.get(URI.parse('http://127.0.0.1/nginx_status')).each_line do |line|
          if line.start_with? ' '
            unless first
              first = line.split[1].to_f
              sleep 1
            else
              second = line.split[1].to_f
            end
          end
        end
      rescue
        second = 0.0
        first = 0.0
      end
    end

    second - first
  end
end
