require File.expand_path('../monitoring_protocols/core', __FILE__)

require File.expand_path('../monitoring_protocols/version', __FILE__)
require File.expand_path('../monitoring_protocols/struct', __FILE__)
require File.expand_path('../monitoring_protocols/parser', __FILE__)

require File.expand_path('../monitoring_protocols/collectd/msg', __FILE__)
require File.expand_path('../monitoring_protocols/collectd/builder', __FILE__)
require File.expand_path('../monitoring_protocols/collectd/parser', __FILE__)

require File.expand_path('../monitoring_protocols/json/parser', __FILE__)


module MonitoringProtocols
  def self.factory_file
    File.expand_path('../../specs/factories.rb', __FILE__)
  end
end
