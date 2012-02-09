require 'spec_helper'

describe "MQ Administration" do
  after(:each) do
    @qm.disconnect if !@qm.nil?
  end

  it "should find an existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("SAMPLE_IN").should_not be_nil    # SAMPLE_IN needs to be changed to one that always exists
  end

  it "should not find a non-existing queue" do
    @qm = RMQ::QueueManager::connect(SpecHelper::DATA[:queue_manager])
    @qm.find_queue("DOES_NOT_EXIST").should be_nil
  end

end
