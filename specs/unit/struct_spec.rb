require File.expand_path('../../spec_helper', __FILE__)

describe 'Packet' do
  before do
    @point = FactoryGirl.build(:data_point)
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
end
