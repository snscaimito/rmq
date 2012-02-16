require 'spec_helper'

describe RMQ::Queue do
  SAMPLE_QUEUE = SpecHelper::DATA[:sample_queue]

  before(:each) do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])

    @qm.delete_queue(SAMPLE_QUEUE) unless @qm.find_queue(SAMPLE_QUEUE).nil?
    @queue = @qm.create_queue(SAMPLE_QUEUE)
  end

  after(:each) do
    begin
      @qm.delete_queue(SAMPLE_QUEUE)
    rescue
      puts "Cannot delete #{SAMPLE_QUEUE}"
    end
    @qm.disconnect if !@qm.nil?
  end

  it "should put a message on a queue" do
    @queue.put_message("sample message")
    @queue.depth.should == 1
  end

  it "should read a message from a queue" do
    @queue.put_message("I want to read this back")
    @queue.get_message_payload.should == "I want to read this back"
  end

  it "should put a message on a queue and use a reply queue name" do
    @queue.put_message("I want to read this back", "REPLY_QUEUE")
    message = @queue.get_message
    message.should_not be_nil
    message.reply_queue_name.should == "REPLY_QUEUE"
  end

  it "should time out waiting for a message" do
    lambda { @queue.get_message(2) }.should raise_error(RMQ::RMQTimeOutError)
  end

end
