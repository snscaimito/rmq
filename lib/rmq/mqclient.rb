module RMQ
  module MQClient
    include Constants
    extend FFI::Library

    ffi_lib "C:\\Program Files (x86)\\IBM\\WebSphere MQ\\bin\\mqic32.dll"
    ffi_convention :stdcall

    attach_function :mqconn, :MQCONN,
                    [:string, :pointer, :pointer, :pointer], :void
    attach_function :mqdisc, :MQDISC,
                    [:pointer, :pointer, :pointer], :void

    # mqCreateBag (Options, &Bag, &CompCode, &Reason)
    attach_function :mqai_create_bag, :mqCreateBag,
                    [:long, :pointer, :pointer, :pointer], :void

    # mqAddString (hBag, Selector, BufferLength, Buffer, &CompCode, &Reason)
    attach_function :mqai_add_string, :mqAddString,
                    [:long, :long, :long, :string, :pointer, :pointer], :void

    # mqAddInteger (Bag, Selector, ItemValue, &CompCode, &Reason)
    attach_function :mqai_add_integer, :mqAddInteger,
                    [:long, :long, :long, :pointer, :pointer], :void

    # mqInquireString (Bag, Selector, ItemIndex, BufferLength, Buffer, &StringLength, &CodedCharSetId, &CompCode, &Reason)
    attach_function :mqai_inquire_string, :mqInquireString,
                    [:long, :long, :long, :long, :pointer, :pointer, :pointer, :pointer, :pointer], :void

    # mqAddInquiry (Bag, Selector, &CompCode, &Reason)
    attach_function :mqai_add_inquiry, :mqAddInquiry,
                    [:long, :long, :pointer, :pointer], :void

    # mqExecute (Hconn, Command, OptionsBag, AdminBag, ResponseBag, AdminQ, ResponseQ, CompCode, Reason)
    attach_function :mqai_execute, :mqExecute,
                    [:long, :long, :long, :long, :long, :long, :long, :pointer, :pointer], :void

    # mqCountItems (Bag, Selector, &ItemCount, &CompCode, &Reason)
    attach_function :mqai_count_items, :mqCountItems,
                    [:long, :long, :pointer, :pointer, :pointer], :void

    # mqInquireBag (Bag, Selector, ItemIndex, &ItemValue, &CompCode, &Reason)
    attach_function :mqai_inquire_bag, :mqInquireBag,
                    [:long, :long, :long, :pointer, :pointer, :pointer], :void

    # mqDeleteBag (&Bag, CompCode, Reason)
    attach_function :mqai_delete_bag, :mqDeleteBag,
                    [:pointer, :pointer, :pointer], :void


    def create_admin_bag
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      adminbag_handle_ptr = FFI::MemoryPointer.new :long
      mqai_create_bag(MQCBO_ADMIN_BAG, adminbag_handle_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot create admin bag" if completion_code_ptr.read_long != MQCC_OK

      adminbag_handle_ptr.read_long
    end

    def create_response_bag
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      responsebag_handle_ptr = FFI::MemoryPointer.new :long
      mqai_create_bag(MQCBO_ADMIN_BAG, responsebag_handle_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot create response bag" if completion_code_ptr.read_long != MQCC_OK

      responsebag_handle_ptr.read_long
    end

    def add_string_to_bag(bag_handle, selector, value)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      mqai_add_string(bag_handle, selector, MQBL_NULL_TERMINATED, value, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add string to admin bag" if completion_code_ptr.read_long != MQCC_OK
    end

    def add_integer_to_bag(bag_handle, selector, value)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      mqai_add_integer(bag_handle, selector, value, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add integer to admin bag" if completion_code_ptr.read_long != MQCC_OK
    end

    def add_inquiry(bag_handle, selector)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      mqai_add_inquiry(bag_handle, selector, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot add inquiry to admin bag" if completion_code_ptr.read_long != MQCC_OK
    end

    def execute(connection_handle, command, options_bag, admin_bag, response_bag,
        admin_queue, response_queue)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      mqai_execute(connection_handle, command, options_bag, admin_bag,
        response_bag, admin_queue, response_queue, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot execute admin bag" if completion_code_ptr.read_long != MQCC_OK
    end

    def count_items(bag_handle, selector)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      number_of_bags_ptr = FFI::MemoryPointer.new :long
      mqai_count_items(bag_handle, selector, number_of_bags_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot count items in response bag" if completion_code_ptr.read_long != MQCC_OK

      number_of_bags_ptr.read_long
    end

    def inquire_bag(bag_handle, selector, item_index)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      item_value_ptr = FFI::MemoryPointer.new :long
      mqai_inquire_bag(bag_handle, selector, item_index, item_value_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire attributes bag handle from response bag" if completion_code_ptr.read_long != MQCC_OK

      item_value_ptr.read_long
    end

    def inquire_string(bag_handle, selector, item_index)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      string_ptr = FFI::MemoryPointer.new :char, 255
      length_ptr = FFI::MemoryPointer.new :long
      mqai_inquire_string(bag_handle, selector, item_index, 255, string_ptr, length_ptr, nil, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire queue name from attributes bag" if completion_code_ptr.read_long != MQCC_OK

      string_ptr.read_string.strip
    end

    def delete_bag(bag_handle)
      unless bag_handle == MQHB_UNUSABLE_HBAG
        completion_code_ptr = FFI::MemoryPointer.new :long
        reason_code_ptr = FFI::MemoryPointer.new :long
        bag_handle_ptr = FFI::MemoryPointer.new :long
        bag_handle_ptr.write_long(bag_handle)

        mqai_delete_bag(bag_handle_ptr, completion_code_ptr, reason_code_ptr)
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot delete bag" if completion_code_ptr.read_long != MQCC_OK
      end
    end

  end
end
