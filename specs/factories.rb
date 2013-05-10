
FactoryGirl.define do
  factory :data_common do
    time { Time.now }
    host "localhost"
    plugin "memory"
    plugin_instance nil
    
    type "memory"
    type_instance "active"
  end
  
  factory :data_point, :parent => :data_common, :class => "MonitoringProtocols::Packet" do
    values { [rand(200)] }
    interval 10
  end
  
  factory :notification, :parent => :data_common, :class => "MonitoringProtocols::Packet" do
    severity 1
    message "notification message"
  end
  
end
