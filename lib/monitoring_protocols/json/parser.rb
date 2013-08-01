require 'oj'

module MonitoringProtocols
  module JSON
  
    # {
    #   type: 'datapoints',
    #   host: 'linux1'
    #   app_name: 'system',
      
    #   cpu: {  
    #     'user'  => 43,
    #     'sys'   => 3.4,
    #     'nice'  => 6.0
    #   },
      
    #   memory: {
    #     'total'  => 2048,
    #     'used'   => 400
    #   }
    # }
    class Parser < Parser
      def self.parse(buffer)
        packets = []
        
        data = Oj.load(buffer)
        
        msg_type = data.delete(:type)
        if msg_type == 'datapoints'
          parse_datapoints(data) do |pkt|
            packets << pkt
          end
        end
        
        packets
      end
      
    private
      def self.parse_datapoints(data)
        host = data.delete(:host)
        app_name = data.delete(:app_name)
        if time = data.delete(:time)
          time = Time.parse(time)
        end
        
        data.each do |res_name, metrics|
          metrics.each do |metric_name, value|
            msg = DataPoint.new(
                host: host,
                time: time,
                app_name: app_name,
                res_name: res_name.to_s,
                metric_name: metric_name.to_s,
                value: value
              )
            
            yield(msg)
          end
        end
      end
      
    end
    
  end
end
