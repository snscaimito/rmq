require 'spec_helper'

describe 'RMQ' do

  after(:each) do
    @qm.disconnect if !@qm.nil?
  end

  it 'should pass the canary test' do
    true.should == true
  end

  it 'should connect/disconnect to/from local queue manager' do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.should_not be_nil
  end

  it "should raise an exception for a wrong queue manager name" do
    lambda { RMQ::QueueManager::connect("INVALID_NAME") }.should raise_error(RMQ::RMQException)
  end

end
