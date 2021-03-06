module MonitoringProtocols
  module Collectd
    
    class Parser < Parser
      
      # part type
      HOST            = 0x0000
      TIME            = 0x0001
      TIME_HR         = 0X0008
      PLUGIN          = 0x0002
      PLUGIN_INSTANCE = 0x0003
      TYPE            = 0x0004
      TYPE_INSTANCE   = 0x0005
      VALUES          = 0x0006
      INTERVAL        = 0x0007
      INTERVAL_HR     = 0X0009
      MESSAGE         = 0x0100
      SEVERITY        = 0x0101
      
      PART_TYPE_AS_STRING = {
          HOST            => 'host',
          TIME            => 'time',
          TIME_HR         => 'time_hr',
          PLUGIN          => 'plugin',
          PLUGIN_INSTANCE => 'plugin_instance',
          TYPE            => 'type',
          TYPE_INSTANCE   => 'type_instance',
          VALUES          => 'values',
          INTERVAL        => 'interval',
          INTERVAL_HR     => 'interval_hr',
          MESSAGE         => 'message',
          SEVERITY        => 'severity'
        }.freeze
      
      STR_FIELDS = [HOST, PLUGIN, PLUGIN_INSTANCE, TYPE, TYPE_INSTANCE, MESSAGE]
      INT_FIELDS = [TIME, TIME_HR, INTERVAL, INTERVAL_HR, SEVERITY]
      
      COUNTER   = 0x00
      GAUGE     = 0x01
      DERIVE    = 0x02
      ABSOLUTE  = 0x03
      
      def self.parse_part_header(buffer)
        type, length, rest = buffer.unpack('nna*')
        [type, length - 4, rest]
      end
      
      INT64_MAX = (1 << 63)
      INT64_SIGN_BIT = (1 << 64)
      
      # uint to int
      # "val = val - #{1 << nbits} if (val >= #{1 << (nbits - 1)})"
      def self.parse_int64(buffer, signed = false)
        # [v>>32, v & 0xffffffff].pack("NN")}.join
        
        hi, lo, buffer = buffer.unpack("NNa*")
        n = (hi << 32 | lo)
        
        if signed && (n >= INT64_MAX)
          n = n - INT64_SIGN_BIT
        end
        
        [n, buffer]
      end
      
      def self.parse_part(buffer)
        type, length, buffer = parse_part_header(buffer)
        case
        when INT_FIELDS.include?(type)  then  val, buffer = parse_int64(buffer)
        when STR_FIELDS.include?(type)  then  val, buffer = buffer.unpack("Z#{length}a*")
        when type == VALUES             then  val, buffer = parse_part_values(length, buffer)
        else
          val, buffer = buffer.unpack("a#{length}a*")
          raise ParseError, "unknown part: #{type}, data: #{val.inspect}"
        end
        
        # just convert to seconds
        if (type == TIME_HR)
          type = TIME
          val = (val >> 30)
        end
        
        if (type == INTERVAL_HR)
          type = INTERVAL
          val = (val >> 30)
          p [:interval, val]
        end
        
        [
          PART_TYPE_AS_STRING[type],
          val,
          buffer
        ]
      end
      
      def self.parse_part_values(length, buffer)
        # first we need to read the types of all the values
        values_count, buffer = buffer.unpack("na*")
        *types, buffer = buffer.unpack("C#{values_count}a*")
        values = types.map! do |type|
          case type
          when COUNTER, ABSOLUTE  then  val, buffer = parse_int64(buffer)
          when GAUGE              then  val, buffer = buffer.unpack("Ea*")
          when DERIVE             then  val, buffer = parse_int64(buffer, true)
          end
          
          val
        end
        
        [values, buffer]
      end
      
      COPY_FIELDS = [
          :time,
          :host,
          :plugin,
          :plugin_instance,
          :type,
          :type_instance,
          :interval
        ].freeze
      
      def self.parse_packet(buffer, initial_values = {})
        packet = NetworkMessage.new(initial_values, COPY_FIELDS)
        
        begin
          type, value, buffer = parse_part(buffer)
          packet.send("#{type}=", value)
        end until packet.message || packet.values
        
        [packet, buffer]
      end
      
      def self.parse(buffer)
        packets = []
        last_packet = {}
        
        # 4 = part header size
        while buffer.bytesize >= 4
          packet, buffer = parse_packet(buffer, last_packet)
          packets << packet
          
          last_packet = packet if packet.data?
        end
        
        packets
      end
      
      # def initialize
      #   @buffer = ""
      #   @last_packet = {}
      # end
      
      # def feed(data)
      #   ret = []
        
      #   @buffer << data
      #   if @buffer.bytesize >= 4
      #     pkt, @buffer = self.class.parse_packet(@buffer, @last_packet)
      #     if pkt.data?
      #       ret << pkt
      #       @last_packet = pack
      #     end
      #   end
        
      #   ret
      # end

    end
    
    
  end
  
  register_parser(:collectd, Collectd::Parser)
end
