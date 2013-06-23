require File.expand_path('../../spec_helper', __FILE__)

describe 'Core' do
  should 'return parser for collectd' do
    MonitoringProtocols.get_parser(:collectd).class.should ==
      MonitoringProtocols::Collectd::Parser
  end
  
  should 'return builder for collectd' do
    MonitoringProtocols.get_builder(:collectd).class.should ==
      MonitoringProtocols::Collectd::Builder
  end

  
  should 'return nil for unknown protocol' do
    MonitoringProtocols.get_parser(:i_am_invalid).should == nil
  end
    
end
