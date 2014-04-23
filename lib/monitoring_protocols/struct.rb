require 'time'
require 'msgpack'
require File.expand_path('../data_struct', __FILE__)

module MonitoringProtocols
  
  class NetworkMessage < DataStruct
    
    ##
    # Return a generic structure representing
    # the content of this message.
    #
    # @return [DataPoint,Notification]
    #
    def convert_content
      raise 'reimplement in subclass'
    end
  end
  
  class CommonData < DataStruct
    properties(
        :time,
        :host,
        :app_name,
        :res_name,
        :metric_name,
      )
    
    def time=(val)
      case val
      when Time     then @time = val
      when Numeric  then @time = Time.at(val).getutc()
      else
        raise "invalid type for time: #{val}"
      end
    end
    
    def measure_id(sep = '-')
      [host, app_name, res_name, metric_name].join(sep)
    end
    
    
    def to_h
      super.merge(
          time: time ? time.iso8601 : nil
        )
    end
    
    def convert_content
      [self]
    end

  end
  
  class DataPoint < CommonData
    properties(
        :value,
        :first
      )
    
    def data?; true; end
    
    def to_h
      super.merge(
          type: 'datapoint'
        )
    end

  end
  
  class Notification < CommonData
    SEVERITY = [:info, :warn, :error].freeze
    
    properties(
        :severity,
        :message
      )
    
    def severity=(val)
      if val.is_a?(Fixnum)
        @severity = SEVERITY[val]
      else
        @severity = val
      end
    end
    
    def data?; false; end
    
    def to_h
      super.merge(
          type: 'notification'
        )
    end

  end
  
end
