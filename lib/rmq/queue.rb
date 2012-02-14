module RMQ
  class Queue
    include MQClient

    def initialize(queue_manager, name)
      @queue_manager = queue_manager
      @queue_name = name
    end

    def put_message(payload)
      @queue_handle = open_queue(@queue_manager.connection_handle, @queue_name, Constants::MQOO_OUTPUT) if @queue_handle.nil?

      put_message_on_queue(@queue_manager.connection_handle, @queue_handle, payload)

      close_queue(@queue_manager.connection_handle, @queue_handle, Constants::MQCO_NONE)
      @queue_handle = nil
    end

    def depth
      queue_depth(@queue_manager.connection_handle, @queue_name)
    end

  end
end