require 'spec_helper'

describe RMQ::QueueManager do

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

  it "should create a new queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    queue = @qm.create_queue("RMQ.SAMPLE")
    queue.should_not be_nil

    @qm.find_queue("RMQ.SAMPLE").should_not be_nil

    @qm.delete_queue("RMQ.SAMPLE")
  end

  it "should find an existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("SYSTEM.ADMIN.COMMAND.QUEUE").should_not be_nil    # SAMPLE_IN needs to be changed to one that always exists
  end

  it "should not find a non-existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("DOES_NOT_EXIST").should be_nil
  end

  it "should delete a queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.create_queue("RMQ.SAMPLE")
    @qm.find_queue("RMQ.SAMPLE").should_not be_nil

    @qm.delete_queue("RMQ.SAMPLE")
    @qm.find_queue("RMQ.SAMPLE").should be_nil
  end

end
