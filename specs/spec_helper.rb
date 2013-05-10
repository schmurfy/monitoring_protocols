require 'rubygems'
require 'bundler/setup'

require 'eetee'

$LOAD_PATH.unshift( File.expand_path('../../lib' , __FILE__) )
require 'monitoring_protocols'

require 'eetee/ext/mocha'
# require 'eetee/ext/em'

require 'factory_girl'
require File.expand_path('../factories', __FILE__)

# Thread.abort_on_exception = true
