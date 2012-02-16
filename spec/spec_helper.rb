require 'rspec'
require 'rmq'

MQSERVER = "SYSTEM.DEF.SVRCONN/TCP/127.0.0.1(1414)"

module SpecHelper
  DATA = {
      :queue_manager => "BKR_QMGR",
      :sample_queue => "RMQ.SAMPLE"
  }
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'

  config.before(:each) do
    ENV['MQSERVER'] = MQSERVER
  end
end
