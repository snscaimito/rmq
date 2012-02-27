require 'spec_helper'

describe RMQ::QueueManager do
  SAMPLE_QUEUE = SpecHelper::DATA[:sample_queue]

  after(:each) do
    begin
      @qm.delete_queue(SAMPLE_QUEUE) if !@qm.find_queue(SAMPLE_QUEUE).nil?
    rescue
      puts "Cannot delete #{SAMPLE_QUEUE}"
    end
    @qm.disconnect if !@qm.nil?
  end

  it 'should connect/disconnect to/from local queue manager' do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.should_not be_nil
  end

  it "should raise an exception for a wrong queue manager name" do
    lambda { RMQ::QueueManager::connect("INVALID_NAME") }.should raise_error(RMQ::RMQException)
  end

  it "should warn about missing MQSERVER environment variable" do
    ENV['MQSERVER'] = ""

    lambda { RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager]) }.should raise_error(RuntimeError)
  end

  it "should create a new queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    queue = @qm.create_queue(SAMPLE_QUEUE)
    queue.should_not be_nil

    @qm.find_queue(SAMPLE_QUEUE).should_not be_nil

    @qm.delete_queue(SAMPLE_QUEUE)
  end

  it "should find an existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("SYSTEM.ADMIN.COMMAND.QUEUE").should_not be_nil
  end

  it "should not find a non-existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("DOES_NOT_EXIST").should be_nil
  end

  it "should delete a queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.create_queue(SAMPLE_QUEUE)
    @qm.find_queue(SAMPLE_QUEUE).should_not be_nil

    @qm.delete_queue(SAMPLE_QUEUE)
    @qm.find_queue(SAMPLE_QUEUE).should be_nil
  end

end
