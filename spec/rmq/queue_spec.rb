require 'spec_helper'

describe RMQ::Queue do

  before(:each) do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])

    @qm.delete_queue("RMQ.SAMPLE") unless @qm.find_queue("RMQ.SAMPLE").nil?
    @queue = @qm.create_queue("RMQ.SAMPLE")
  end

  after(:each) do
    @qm.delete_queue("RMQ.SAMPLE")
    @qm.disconnect if !@qm.nil?
  end

  it "should put a message on a queue" do
    @queue.put_message("sample message")
    @queue.depth.should == 1
  end

  it "should read a message from a queue" do
    @queue.put_message("I want to read this back")
    @queue.get_message.should == "I want to read this back"
  end

  it "should put a message on a queue and use a reply queue name" do

  end

end
