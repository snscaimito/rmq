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
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      adminbag_handle_ptr = FFI::MemoryPointer.new :long
      mqai_create_bag(MQCBO_ADMIN_BAG, adminbag_handle_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot create admin bag" if completion_code_ptr.read_long != MQCC_OK
      adminbag_handle = adminbag_handle_ptr.read_long

      responsebag_handle_ptr = FFI::MemoryPointer.new :long
      mqai_create_bag(MQCBO_ADMIN_BAG, responsebag_handle_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot create response bag" if completion_code_ptr.read_long != MQCC_OK
      responsebag_handle = responsebag_handle_ptr.read_long

      mqai_add_string(adminbag_handle, MQCA_Q_NAME, MQBL_NULL_TERMINATED,
        "*", completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add string to admin bag" if completion_code_ptr.read_long != MQCC_OK

      mqai_add_integer(adminbag_handle, MQIA_Q_TYPE, MQQT_LOCAL, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add integer to admin bag" if completion_code_ptr.read_long != MQCC_OK

      mqai_add_inquiry(adminbag_handle, MQIA_CURRENT_Q_DEPTH, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add inquiry to admin bag" if completion_code_ptr.read_long != MQCC_OK

      mqai_execute(@hconn, MQCMD_INQUIRE_Q, MQHB_NONE, adminbag_handle,
        responsebag_handle, MQHO_NONE, MQHO_NONE, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot execute admin bag" if completion_code_ptr.read_long != MQCC_OK

      number_of_bags_ptr = FFI::MemoryPointer.new :long
      mqai_count_items(responsebag_handle, MQHA_BAG_HANDLE, number_of_bags_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot count items in response bag" if completion_code_ptr.read_long != MQCC_OK
      number_of_bags = number_of_bags_ptr.read_long

      queue_names = []
      for bag_number in (0..number_of_bags - 1)
        attributes_bag_ptr = FFI::MemoryPointer.new :long
        mqai_inquire_bag(responsebag_handle, MQHA_BAG_HANDLE, bag_number, attributes_bag_ptr, completion_code_ptr, reason_code_ptr)
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire attributes bag handle from response bag" if completion_code_ptr.read_long != MQCC_OK
        attributes_bag_handle = attributes_bag_ptr.read_long

        queue_name_ptr = FFI::MemoryPointer.new :char, MQ_Q_NAME_LENGTH
        queue_name_length_ptr = FFI::MemoryPointer.new :long
        mqai_inquire_string(attributes_bag_handle, MQCA_Q_NAME, 0, MQ_Q_NAME_LENGTH, queue_name_ptr, queue_name_length_ptr, nil, completion_code_ptr, reason_code_ptr)
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire queue name from attributes bag" if completion_code_ptr.read_long != MQCC_OK

        queue_names.push queue_name_ptr.read_string.strip
      end

      if queue_names.include?(queue_name)
        RMQ::Queue.new(queue_name)
      else
        nil
      end
    end

  end
end
