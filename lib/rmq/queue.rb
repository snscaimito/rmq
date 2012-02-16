module RMQ
  class Queue
    include MQClient

    # TODO add some caching for the queue handle

    def initialize(queue_manager, name)
      @queue_manager = queue_manager
      @queue_name = name
    end

    # Puts a message onto the queue. A reply to queue name can be specified.
    def put_message(payload, reply_queue_name = "")
      @queue_handle = open_queue(@queue_manager.connection_handle, @queue_name, Constants::MQOO_OUTPUT) if @queue_handle.nil?

      put_message_on_queue(@queue_manager.connection_handle, @queue_handle, payload, reply_queue_name)

      close_queue(@queue_manager.connection_handle, @queue_handle, Constants::MQCO_NONE)
      @queue_handle = nil
    end

    def depth
      queue_depth(@queue_manager.connection_handle, @queue_name)
    end

    # Gets a message from the queue. A timeout period can be specified in seconds.
    def get_message(timeout = 0)
      @queue_handle = open_queue(@queue_manager.connection_handle, @queue_name, Constants::MQOO_INPUT_SHARED) if @queue_handle.nil?

      if (timeout > 0)
        begin_time = Time.now.to_i
        begin
          message = get_message_from_queue(@queue_manager.connection_handle, @queue_handle, timeout)
        rescue RMQException
          end_time = Time.now.to_i
          raise RMQTimeOutError.new if end_time - begin_time >= timeout
        end
      else
        message = get_message_from_queue(@queue_manager.connection_handle, @queue_handle, 0)
      end

      close_queue(@queue_manager.connection_handle, @queue_handle, Constants::MQCO_NONE)
      @queue_handle = nil

      message
    end

    # Gets a message from the queue and returns the payload only. A timeout period can be specified
    # in seconds.
    def get_message_payload(timeout = 0)
      message = get_message(timeout)
      message.payload
    end
  end
end