require 'factory_girl'

FactoryGirl.define do
  factory :collectd_data_common do
    time { Time.now }
    host "localhost"
    plugin "memory"
    plugin_instance nil
    
    type "memory"
    type_instance "active"
  end
  
  factory :collectd_data_point, :parent => :collectd_data_common, :class => "MonitoringProtocols::Collectd::NetworkMessage" do
    values { [rand(200)] }
    interval 10
  end
  
  factory :collectd_notification, :parent => :collectd_data_common, :class => "MonitoringProtocols::Collectd::NetworkMessage" do
    severity 1
    message "notification message"
  end
  
  
  factory :data_common do
    time { Time.now }
    host "localhost"
    app_name "system"
    res_name "memory"
    metric_name "active"
    
    initialize_with{ new(time: time) }
  end
  
  factory :data_point, :parent => :data_common, :class => "MonitoringProtocols::DataPoint" do
    value { rand(200) }
  end
  
  factory :notification, :parent => :data_common, :class => "MonitoringProtocols::Notification" do
    severity :error
    message "notification message"
  end
  
end
