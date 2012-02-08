require 'rmq/mqclient'

module RMQ
  class QueueManager
    include MQClient

    def self.connect(queue_manager)
      qm = QueueManager.new(queue_manager)
      qm.connect

      qm
    end

    def initialize(queue_manager)
      @queue_manager = queue_manager
    end

    def connect
      hconn_ptr = FFI::MemoryPointer.new :long
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      MQClient.mqconn(@queue_manager, hconn_ptr, completion_code_ptr, reason_code_ptr)

      @hconn = hconn_ptr.read_long

      unless completion_code_ptr.read_long == RMQ::MQCC_OK
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot connect to queue manager #{@queue_manager}"
      end
    end

    def disconnect
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long
      hconn_ptr = FFI::MemoryPointer.new :long

      hconn_ptr.write_long @hconn
      MQClient.mqdisc(hconn_ptr, completion_code_ptr, reason_code_ptr)

      unless completion_code_ptr.read_long == RMQ::MQCC_OK
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot disconnect from queue manager #{@queue_manager}"
      end
    end

  end
end
