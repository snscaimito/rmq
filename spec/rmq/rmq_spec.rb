require 'spec_helper'

describe 'RMQ' do

  it 'should pass the canary test' do
    true.should == true
  end

  it 'should connect to local queue manager' do
    qm = QueueManager::connect(SpecHelper::DATA[:queue_manager])
    qm.should_not be_nil
  end

  it "should raise an exception for a wrong queue manager name" do
    lambda { QueueManager::connect("INVALID_NAME") }.should raise_error(RMQException)
  end

end
