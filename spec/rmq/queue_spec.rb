require 'spec_helper'

describe RMQ::Queue do

  before(:each) do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @queue = @qm.create_queue("RMQ.SAMPLE")
  end

  after(:each) do
    if @qm.find_queue("RMQ.SAMPLE").nil? == false
      puts "RMQ Sample exists"
    end
    @qm.delete_queue("RMQ.SAMPLE")
    @qm.disconnect if !@qm.nil?
  end

  it "should put a message on a queue" do
    @queue.put_message("sample message")
    @queue.depth.should == 1
  end

end
