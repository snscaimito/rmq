require 'spec_helper'

describe 'RMQ' do

  it 'should pass the canary test' do
    true.should == true
  end

  it 'should connect to local queue manager' do
    ENV['MQSERVER'] = "SYSTEM.DEF.SVRCONN/TCP/127.0.0.1(1414)"
    qm = QueueManager::connect(SpecHelper::DATA[:queue_manager])
    qm.should_not be_nil
  end
end
