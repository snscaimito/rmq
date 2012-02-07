require 'rspec'
require 'rmq'

module SpecHelper
  DATA = {
      :queue_manager => "BKR_QMGR"
  }
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
