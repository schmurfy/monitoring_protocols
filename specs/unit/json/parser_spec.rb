require File.expand_path('../../../spec_helper', __FILE__)

describe 'JSON Ruby parser' do
  before do
    @parser_class = MonitoringProtocols::JSON::Parser
  end
  
  describe 'with common app_name' do
    
    describe 'One point in buffer' do
      before do
        @now = Time.new.utc
        @json = Oj.dump({
              'type' => 'datapoints',
              'host' => 'hostname',
              'app_name' => 'system',
              'time' => @now.iso8601,
              
              'cpu' => {
                  'user' => 1,
              }
            },
            indent: -1
          )
      end
      
      should 'parse buffer' do
        msgs = @parser_class.parse(@json)
        msgs.size.should == 1
        
        msgs[0].class.should            == MonitoringProtocols::DataPoint
        msgs[0].host.should             == 'hostname'
        msgs[0].time.to_i.should        == @now.to_i
        msgs[0].app_name.should         == 'system'
        msgs[0].res_name.should         == 'cpu'
        msgs[0].metric_name.should      == 'user'
        msgs[0].value.should            == 1
      end
    end
    
    
    describe 'Multiple points in buffer' do
      before do
        @now = Time.new.utc
        @json = Oj.dump({
              'type' => 'datapoints',
              'host' => 'hostname',
              'app_name' => 'system',
              'time' => @now.iso8601,
              
              'cpu' => {
                  'user' => 1,
                  'sys' => 2
              },
              
              'memory' => {
                  'total' => 4,
                  'used' => 1,
                  'free' => 3
              }
            },
            indent: -1
          )
        
      end
      
      should 'parse buffer' do
        msgs = @parser_class.parse(@json)
        msgs.size.should == 5
        
        common_check = ->(m){
          m.class.should            == MonitoringProtocols::DataPoint
          m.host.should             == 'hostname'
          m.time.to_i.should        == @now.to_i
          m.app_name.should         == 'system'
        }
        
        msgs[0].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'user'
          m.value.should            == 1
        end
        
        msgs[1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'sys'
          m.value.should            == 2
        end
        
        msgs[2].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'total'
          m.value.should            == 4
        end
        
        msgs[3].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'used'
          m.value.should            == 1
        end
        
        msgs[4].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'free'
          m.value.should            == 3
        end



      end
    end
    
  end
  
  
  describe 'with different app_name' do
    
    describe 'One point in buffer' do
      before do
        @now = Time.new.utc
        @json = Oj.dump({
              'type' => 'datapoints',
              'host' => 'hostname',
              'time' => @now.iso8601,
              
              'system' => {
                'cpu' => {
                    'user' => 1,
                }
              }
            },
            indent: -1
          )
      end
      
      should 'parse buffer' do
        msgs = @parser_class.parse(@json)
        msgs.size.should == 1
        
        msgs[0].class.should            == MonitoringProtocols::DataPoint
        msgs[0].host.should             == 'hostname'
        msgs[0].time.to_i.should        == @now.to_i
        msgs[0].app_name.should         == 'system'
        msgs[0].res_name.should         == 'cpu'
        msgs[0].metric_name.should      == 'user'
        msgs[0].value.should            == 1
      end
    end
    
    
    describe 'Multiple points in buffer' do
      before do
        @now = Time.new.utc
        @json = Oj.dump({
              'type' => 'datapoints',
              'host' => 'hostname',
              'time' => @now.iso8601,
              
              'system2' => {
                'cpu' => {
                    'user' => 45,
                    'sys' => 27
                }
              },
              
              'system' => {
                'cpu' => {
                    'user' => 1,
                    'sys' => 2
                },
                
                'memory' => {
                    'total' => 4,
                    'used' => 1,
                    'free' => 3
                }
              }
            },
            indent: -1
          )
        
      end
      
      should 'parse buffer' do
        msgs = @parser_class.parse(@json)
        msgs.size.should == 7
        
        common_check = ->(m, app_name = 'system'){
          m.class.should            == MonitoringProtocols::DataPoint
          m.host.should             == 'hostname'
          m.time.to_i.should        == @now.to_i
          m.app_name.should         == app_name
        }
        
        index = -1
        
        msgs[index += 1].tap do |m|
          common_check.call(m, 'system2')
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'user'
          m.value.should            == 45
        end

        msgs[index += 1].tap do |m|
          common_check.call(m, 'system2')
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'sys'
          m.value.should            == 27
        end

        
        msgs[index += 1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'user'
          m.value.should            == 1
        end
        
        msgs[index += 1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'cpu'
          m.metric_name.should      == 'sys'
          m.value.should            == 2
        end
        
        msgs[index += 1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'total'
          m.value.should            == 4
        end
        
        msgs[index += 1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'used'
          m.value.should            == 1
        end
        
        msgs[index += 1].tap do |m|
          common_check.call(m)
          m.res_name.should         == 'memory'
          m.metric_name.should      == 'free'
          m.value.should            == 3
        end
    
      end
    end
    
  end

  
end
