require 'msgpack'

module MonitoringProtocols
  module MsgPack
  
    class Parser < JSON::Parser
      def self._parse(buffer)
        MessagePack.unpack(buffer)
      end
      
    end
    
  end
  
  register_parser(:msgpack, MsgPack::Parser)
end
