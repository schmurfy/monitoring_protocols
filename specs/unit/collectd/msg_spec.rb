require File.expand_path('../../../spec_helper', __FILE__)

describe 'Collectd Network Message' do
  
  describe 'data point' do
    before do
      @time_obj = Time.now
      @time = @time_obj.to_i
      
      @point = FactoryGirl.build(:collectd_data_point,
          time: @time,
          type: 'memory',
          type_instance: 'active'
        )
      
      @point.time.should == @time
    end

    should 'return formatted plugin' do
      @point.plugin = "plugin"
      @point.plugin_instance = nil

      @point.plugin_display.should == "plugin"

      @point.plugin_instance = "instance"
      @point.plugin_display.should == "plugin/instance"
    end

    should 'return formatted type' do
      @point.type = "type"
      @point.type_instance = nil

      @point.type_display.should == "type"

      @point.type_instance = "instance"
      @point.type_display.should == "type/instance"
    end
    
    
    should 'convert datapoint to DataPoint' do
      d = @point.convert_content()
      d.class.should == Array
      d.size.should == 1
      
      d = d.first
      d.class.should == MonitoringProtocols::DataPoint
      
      d.first.should != true
      d.host.should == @point.host
      d.time.gmt_offset.should == 0
      d.time.iso8601().should == @time_obj.getutc().iso8601()
      
      d.app_name.should == @point.plugin
      d.res_name.should == @point.type
      d.metric_name.should == @point.type_instance
      d.value.should == d.value
    end
    
  end
  
  
  describe 'notification' do
    before do
      @point = FactoryGirl.build(:collectd_notification,
          type: 'memory',
          type_instance: 'active',
          
          severity: 1,
          message: 'ahhhhhhh'
        )
    end


    should 'convert notification to Notification' do
      d = @point.convert_content()
      d.class.should == Array
      d.size.should == 1
      d = d.first
      d.class.should == MonitoringProtocols::Notification
      
      d.host.should == @point.host
      d.app_name.should == @point.plugin
      d.res_name.should == @point.type
      d.metric_name.should == @point.type_instance
      
      d.severity.should == :warn
      d.message.should == "ahhhhhhh"
    end
    
  end  
  
end

