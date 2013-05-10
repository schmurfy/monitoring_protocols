require File.expand_path('../../../spec_helper', __FILE__)

describe 'Collectd Builder' do
  before do
    @builder = MonitoringProtocols::Collectd::Builder.new
    
    @builder.host = "localhost"
    @builder.time = 1
    @builder.interval = 10
    @builder.plugin = "plugin"
    @builder.plugin_instance = "plugin_instance"
    @builder.type = "type"
    @builder.type_instance = "type_instance"
    @builder.add_value(:counter, 42)
    @builder.add_value(:gauge, 5.24)
  end
  
  it 'can generate a packet' do
    expected = [
        "\x00\x00\x00\x0elocalhost\x00",                    # host
        "\x00\x01\x00\x0c\x00\x00\x00\x00\x00\x00\x00\x01", # time
        "\x00\x07\x00\x0c\x00\x00\x00\x00\x00\x00\x00\x0a", # interval
        "\x00\x02\x00\x0bplugin\x00",                       # plugin
        "\x00\x03\x00\x14plugin_instance\x00",              # plugin_instance
        "\x00\x04\x00\x09type\x00",                         # type
        "\x00\x05\x00\x12type_instance\x00",                # type_instance
        "\x00\x06\x00\x18\x00\x02", # value headers
        "\00\01", # types
        "\x00\x00\x00\x00\x00\x00\x00\x2a",  # value
        "\xf6\x28\x5c\x8f\xc2\xf5\x14\x40"   # value2
      ]
    
    if "".respond_to?(:encode)
      expected = expected.map{|s| s.force_encoding('ASCII-8BIT') }
    end
    
    data = @builder.build_packet
    
    data[0,14].should == expected[0]
    data[14,12].should == expected[1]
    data[26,12].should == expected[2]
    data[38,11].should == expected[3]
    data[49,20].should == expected[4]
    data[69, 9].should == expected[5]
    data[78,18].should == expected[6]
        
    data[96,6].should  == expected[7]
    
    # types
    data[102,2].should == expected[8]
    
    # value1
    data[104,8].should == expected[9]
    # value2
    data[112,8].should == expected[10]
  end
  
end
