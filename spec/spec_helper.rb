require 'rspec'
require 'rmq'

ENV['MQSERVER'] = "SYSTEM.DEF.SVRCONN/TCP/127.0.0.1(1414)"

module SpecHelper
  DATA = {
      :queue_manager => "BKR_QMGR"
  }
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
