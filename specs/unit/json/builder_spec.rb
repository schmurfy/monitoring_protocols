require File.expand_path('../../../spec_helper', __FILE__)

describe 'JSON Ruby builder' do
  before do
    @parser_class = MonitoringProtocols::JSON::Parser
    @builder_class = MonitoringProtocols::JSON::Builder
    @now = Time.new.utc
  end
  
  should 'generate json for points' do
    expected_hash = {
      'type'      => 'datapoints',
      'host'      => 'linux1',
      'app_name'  => 'system',
      
      'cpu'       => {
        'user' => 43.0,
        'sys'  => 3.4
      }
    }
    
    common_data = {
      host: 'linux1',
      app_name: 'system',
      res_name: 'cpu'
    }
    
    points = [
      FactoryGirl.build(:data_point, common_data.merge(
          time: @now,
          metric_name: 'user',
          value: 43.0
        )),
      
      FactoryGirl.build(:data_point, common_data.merge(
          time: @now,
          metric_name: 'sys',
          value: 3.4
        ))
    ]
    
    b = @builder_class.new(points.dup)
    ret = b.build_packet()
    ret.class.should == String
    
    ret = freeze_time(@now){ @parser_class.new.parse(ret) }
    ret.should == points.sort
  end
end
