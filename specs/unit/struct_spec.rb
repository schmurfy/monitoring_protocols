require File.expand_path('../../spec_helper', __FILE__)

describe 'Generic Network Message' do
  before do
    @now = Time.now
    
    @base_data = {
      time: @now,
      host: 'local',
      app_name: 'app',
      res_name: 'res',
      metric_name: 'metric',
    }
  end
  
  describe 'DataPoint' do
    before do
      @p = MonitoringProtocols::DataPoint.new(
          @base_data.merge(value: 2.45)
        )  
    end
    
    should 'have working factory' do
      point = FactoryGirl.build(:data_point)
      point.should.not == nil
    end
    
    should 'have all fields' do
      @p.time.should == @now
      @p.host.should == 'local'
      @p.app_name.should == 'app'
      @p.value.should == 2.45
    end
    
    it 'can be encoded with msgpack' do
      data = MessagePack.pack(@p)
      h = MessagePack.unpack(data)
      h.class.should == Hash
      
      h['type'].should == 'datapoint'
      h['time'].should == @p.time.iso8601()
      h['host'].should == @p.host
      h['app_name'].should == @p.app_name
      h['res_name'].should == @p.res_name
      h['metric_name'].should == @p.metric_name
      h['value'].should == 2.45
    end
  end
  
  
  describe 'Notification' do
    before do
      @n = MonitoringProtocols::Notification.new(
          @base_data.merge(severity: 0, message: 'I saw a horse')
        )
    end
    
    should 'have all fields' do
      @n.time.should == @now
      @n.host.should == 'local'
      @n.app_name.should == 'app'
      @n.severity.should == :info
      @n.message.should == 'I saw a horse'
    end
    
    it 'can be encoded with msgpack' do
      data = MessagePack.pack(@n)
      h = MessagePack.unpack(data)
      h.class.should == Hash
      
      h['type'].should == 'notification'
      h['time'].should == @n.time.iso8601()
      h['host'].should == @n.host
      h['app_name'].should == @n.app_name
      h['res_name'].should == @n.res_name
      h['metric_name'].should == @n.metric_name
      h['severity'].should == 'info'
      h['message'].should == 'I saw a horse'
    end

  end
  
end
