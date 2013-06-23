require File.expand_path('../../spec_helper', __FILE__)

describe 'Parser' do
  
  should 'call parse class method by default' do
    n = 0
    
    parser = Class.new(MonitoringProtocols::Parser)
    parser.define_singleton_method(:parse) do |data|
      n = 2
    end
    
    p = parser.new
    p.parse("data")
    n.should == 2
  end
  
end
