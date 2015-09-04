require 'oj'

module MonitoringProtocols
  module JSON
  
    # {
    #   type: 'datapoints',
    #   host: 'linux1'
    #   app_name: 'system',
    #
    #   cpu: {
    #     'user'  => 43,
    #     'sys'   => 3.4,
    #     'nice'  => 6.0
    #   },
    #
    #   memory: {
    #     'total'  => 2048,
    #     'used'   => 400
    #   }
    # }
    
    # {
    #   type: 'datapoints',
    #   app_name: 'system',
    #
    #   linux1: =>
    #     cpu: {
    #       'user'  => 43,
    #       'sys'   => 3.4,
    #       'nice'  => 6.0
    #     },
    #
    #     memory: {
    #       'total'  => 2048,
    #       'used'   => 400
    #     }
    #   }
    # }
    #
    class Parser < Parser
      
      def self._parse(buffer)
        Oj.load(buffer, symbol_keys: false)
      end
      
      def self.parse(buffer)
        packets = []
        
        data = _parse(buffer)
        
        msg_type = data.delete('type')
        
        if msg_type == 'datapoints'
          parse_datapoints(data) do |pkt|
            packets << pkt
          end
        end
        
        packets
        
      rescue Oj::ParseError, MonitoringProtocols::ParseError
        puts "Unable to parse: #{buffer}"
        []
      end
      
    private
      def self.recursive_parse(point_data, next_fields, field_index, json_document, &block)
        root_field = next_fields[field_index]
        
        json_document.each do |name, value|
          if root_field == :metric_name
            point_data[root_field.to_sym] = name
            point_data[:value] = parse_and_validate_value(value)
            
            msg = DataPoint.new(point_data)
            block.call(msg)
          else
            point_data[root_field] = name
            recursive_parse(point_data, next_fields, field_index + 1, value, &block)
          end
        end
      end
      
      def self.parse_datapoints(data, &block)
        common_data = {}
        
        common_data[:host]     = data.delete('host')
        common_data[:app_name] = data.delete('app_name')
        common_data[:res_name] = data.delete('app_name')
        common_data[:first] = data.delete('first')
        
        if time = data.delete('time')
          common_data[:time] = Time.parse(time)
        else
          common_data[:time] = Time.now.utc()
        end
        
        # find which field we expect as the toplevel of the
        # json document
        next_fields = [:host, :app_name, :res_name, :metric_name]
        field_index = 0
        while (field_index < next_fields.size) && (common_data[next_fields[field_index]] != nil)
          field_index+= 1
        end
        
        recursive_parse(common_data, next_fields, field_index, data, &block)
      end
      
    end
    
  end
  
  register_parser(:json, JSON::Parser)
end
