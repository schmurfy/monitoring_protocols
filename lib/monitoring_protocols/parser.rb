module MonitoringProtocols
  
  ParseError = Class.new(RuntimeError)
  
  class Parser
    
    def parse(data)
      self.class.parse(data)
    end
    
  end
end
