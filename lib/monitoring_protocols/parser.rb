module MonitoringProtocols
  
  ParseError = Class.new(RuntimeError)
  
  class Parser
    
    def parse(data)
      self.class.parse(data)
    end
  
  private
    def self.parse_and_validate_value(v)
      case v
      when Fixnum, Bignum     then v
      when Float, BigDecimal  then ((v * 1000).to_i) / 1000.0
      else
        raise ParseError, "invalid value: #{v} [#{v.class}]"
      end
    end
    
  end
end
