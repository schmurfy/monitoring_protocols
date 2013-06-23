module MonitoringProtocols
  @@parsers  = {}
  @@builders = {}
  
  def self.register_parser(name, parser_class)
    @@parsers[name] = parser_class
  end
  
  def self.register_builder(name, builder_class)
    @@builders[name] = builder_class
  end
  
  def self.get_parser(protocol)
    klass = @@parsers[protocol.to_sym]
    klass ? klass.new : nil
  end
  
  def self.get_builder(protocol)
    klass = @@builders[protocol.to_sym]
    klass ? klass.new : nil
  end
  
end
