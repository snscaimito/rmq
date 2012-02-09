require 'rmq/mqclient'

module RMQ
  class QueueManager
    include MQClient
    include Constants

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

      unless completion_code_ptr.read_long == MQCC_OK
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot connect to queue manager #{@queue_manager}"
      end
    end

    def disconnect
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long
      hconn_ptr = FFI::MemoryPointer.new :long

      hconn_ptr.write_long @hconn
      MQClient.mqdisc(hconn_ptr, completion_code_ptr, reason_code_ptr)

      unless completion_code_ptr.read_long == MQCC_OK
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot disconnect from queue manager #{@queue_manager}"
      end
    end

    def find_queue(queue_name)
      queue_names = []

      adminbag_handle = create_admin_bag
      responsebag_handle = create_response_bag
      add_string_to_bag(adminbag_handle, MQCA_Q_NAME, "*")
      add_integer_to_bag(adminbag_handle, MQIA_Q_TYPE, MQQT_LOCAL)
      add_inquiry(adminbag_handle, MQIA_CURRENT_Q_DEPTH)

      execute(@hconn, MQCMD_INQUIRE_Q, MQHB_NONE, adminbag_handle, responsebag_handle, MQHO_NONE, MQHO_NONE)

      number_of_bags = count_items(responsebag_handle, MQHA_BAG_HANDLE)

      for bag_number in (0..number_of_bags - 1)
        attributes_bag_handle = inquire_bag(responsebag_handle, MQHA_BAG_HANDLE, bag_number)
        queue_names.push inquire_string(attributes_bag_handle, MQCA_Q_NAME, 0)
      end

      if queue_names.include?(queue_name)
        RMQ::Queue.new(queue_name)
      else
        nil
      end
    end

    def create_queue(queue_name)

    end

  end
end
