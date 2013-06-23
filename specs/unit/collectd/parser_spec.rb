require File.expand_path('../../../spec_helper', __FILE__)

class EEtee::Context
  def builder
    MonitoringProtocols::Collectd::Builder
  end
end

describe 'Collectd Ruby parser' do
  before do
    @builder_class = MonitoringProtocols::Collectd::Builder
    @packet = ->(cmd, *args){
      @builder_class.send(cmd, *args)
    }
    
    @parser_class = MonitoringProtocols::Collectd::Parser
  end
    
  describe 'Simple packets' do
    it 'can parse numbers' do
      type, val, buffer = @parser_class.parse_part( builder.number(1, 122) )
      buffer.should == ""
      val.should == 122
      
      type, val, _ = @parser_class.parse_part( builder.number(1, 2500) )
      val.should == 2500
      
      type, val, _ = @parser_class.parse_part( builder.number(1, 356798) )
      val.should == 356798
    end
    
    should 'parse strings' do
      type, str, _ = @parser_class.parse_part( builder.string(0, "hostname1") )
      str.should == 'hostname1'
      
      type, str, _ = @parser_class.parse_part( builder.string(0, "string with spaces") )
      str.should == 'string with spaces'
      
      type, str, _ = @parser_class.parse_part( builder.string(0, "a really long string with many words in it") )
      str.should == 'a really long string with many words in it'
    end
    
    should 'parse values' do
      buffer = builder.values(
          [builder::COUNTER, builder::DERIVE, builder::DERIVE],
          [1034, -4567, 34]
        )
        
      type, values, rest = @parser_class.parse_part( buffer )
      rest.should == ""
      values.should == [1034, -4567, 34]
    end
  end
  
  describe 'One notification in buffer' do
    before do
      @now = Time.new.to_i
      
      @pkt = ""
      @pkt << builder.number(1, @now)
      @pkt << builder.string(0, 'hostname')
         
      @pkt << builder.string(2, 'plugin')
      @pkt << builder.string(3, 'plugin_inst')
      @pkt << builder.string(4, 'type')
      @pkt << builder.string(5, 'type_inst')
      @pkt << builder.number(257, 2) # severity
      @pkt << builder.string(256, 'a message')
    end
    
    should 'parse the notification' do
      data, rest = @parser_class.parse_packet(@pkt)
      
      rest.should == ""
      
      data.class.should             == MonitoringProtocols::Collectd::NetworkMessage
      data.host.should              == 'hostname'
      data.time.should              == @now
      data.plugin.should            == 'plugin'
      data.plugin_instance.should   == 'plugin_inst'
      data.type.should              == 'type'
      data.type_instance.should     == 'type_inst'
      data.message.should           == 'a message'
      data.severity.should          == 2
      
    end
  end
  
  describe 'One packet in buffer' do
    before do
      @now = Time.new.to_i
      @interval = 10
      
      pkt = builder.new
      pkt.time = @now
      pkt.host = 'hostname'
      pkt.interval = @interval
      pkt.plugin = 'plugin'
      pkt.plugin_instance = 'plugin_inst'
      pkt.type = 'type'
      pkt.type_instance = 'type_inst'
      
      pkt.add_value(:counter, 1034)
      pkt.add_value(:gauge, 3.45)
               
      @pkt = pkt.build_packet
    end
    
    should 'parse buffer' do
      data, rest = @parser_class.parse_packet(@pkt)
      
      data.class.should            == MonitoringProtocols::Collectd::NetworkMessage
      data.host.should             == 'hostname'
      data.time.should             == @now
      data.interval.should         == @interval
      data.plugin.should           == 'plugin'
      data.plugin_instance.should  == 'plugin_inst'
      data.type.should             == 'type'
      data.type_instance.should    == 'type_inst'
      
      data.values.size.should      == 2
      data.values[0].should        == 1034
      data.values[1].should        == 3.45
      
      rest.should == ""
    end
  end
  
  describe "Multiple packets in buffer" do
     before do
       @now = Time.new.to_i
       @interval = 10
   
       pkt = builder.new
       pkt.time = @now
       pkt.host = 'hostname'
       pkt.interval = @interval
       pkt.plugin = 'plugin'
       pkt.plugin_instance = 'plugin_inst'
       pkt.type = 'type'
       pkt.type_instance = 'type_inst'
       
       pkt.add_value(:counter, 1034)
       pkt.add_value(:gauge, 3.45)
                
       @pkt = pkt.build_packet
       
       @pkt << builder.string(2, 'plugin2')
       @pkt << builder.string(3, 'plugin2_inst')
       @pkt << builder.string(4, 'type2')
       @pkt << builder.string(5, 'type2_inst')
       
       @pkt << builder.values([builder::COUNTER], [42])
  
       
       @pkt << builder.string(5, 'type21_inst')
       @pkt << builder.values([builder::GAUGE], [3.1415927])
     end
     
     should 'parse buffer' do
       data = @parser_class.parse(@pkt)
       
       data.size.should == 3
       
       data[0].class.should == MonitoringProtocols::Collectd::NetworkMessage
       
       data[0].host.should              == 'hostname'
       data[0].time.should              == @now
       data[0].interval.should          == @interval
       data[0].plugin.should            == 'plugin'
       data[0].plugin_instance.should   == 'plugin_inst'
       data[0].type.should              == 'type'
       data[0].type_instance.should     == 'type_inst'
       data[0].values.size.should       == 2
       data[0].values[0].should         == 1034
       data[0].values[1].should         == 3.45
       
       data[1].host.should              == 'hostname'
       data[1].time.should              == @now
       data[1].interval.should          == @interval
       data[1].plugin.should            == 'plugin2'
       data[1].plugin_instance.should   == 'plugin2_inst'
       data[1].type.should              == 'type2'
       data[1].type_instance.should     == 'type2_inst'
       data[1].values.size.should       == 1
       data[1].values[0].should         == 42
       
       data[2].host.should              == 'hostname'
       data[2].time.should              == @now
       data[2].interval.should          == @interval
       data[2].plugin.should            == 'plugin2'
       data[2].plugin_instance.should   == 'plugin2_inst'
       data[2].type.should              == 'type2'
       data[2].type_instance.should     == 'type21_inst'
       data[2].values.size.should       == 1
       data[2].values[0].should         == 3.1415927
       
     end
     
     # should 'parse using feed interface' do
     #  parser = @parser.new
      
     #  ret = parser.feed(@pkt[0,20])
     #  ret.size.should == []
      
     #  ret = parser.feed(@pkt[21..-1])
     #  ret.size.should == 2
     # end
     
   end
  
end
