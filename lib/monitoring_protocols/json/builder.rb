require 'oj'

module MonitoringProtocols
  module JSON
    KEYS = %i(host app_name res_name metric_name value).freeze
    COMPRESSABLE_KEYS = %i(host app_name).freeze
    
    class Builder < Builder
      def build_packet
        # first we need to find common properties
        json = {type: 'datapoints'}
        
        COMPRESSABLE_KEYS.each do |attr_name|
          v = @points[0].send(attr_name)
          if @points.all?{|p| p.send(attr_name) == v }
            json[attr_name] = v
          end
        end
        
        points_left = @points
        
        
        # find the root key
        keys_left = KEYS.select{|key| !json.has_key?(key) }
        
        raise "unsupported" unless keys_left.size == 3
        
        # now fill the rest
        until points_left.empty?
          p = points_left.pop()
          
          json[p.res_name] ||= {}
          json[p.res_name][p.metric_name] = p.value
        end
        
        Oj.dump(json, symbol_keys: false, mode: :compat)
      end
    end
    
  end
end
