module RMQ
  module MQClient
    include Constants
    extend FFI::Library

    def MQClient.running_on_windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def MQClient.running_on_linux?
      RUBY_PLATFORM.include?("linux")
    end

    ffi_lib "mqic32.dll" if running_on_windows?
    ffi_lib "libmqic" if running_on_linux?
    ffi_convention :stdcall

    attach_function :mqconn, :MQCONN,
                    [:string, :pointer, :pointer, :pointer], :void
    attach_function :mqdisc, :MQDISC,
                    [:pointer, :pointer, :pointer], :void

    # MQPUT (Hconn, Hobj, &MsgDesc, &PutMsgOpts, BufferLength, &Buffer, &CompCode, &Reason)
    attach_function :mqput, :MQPUT,
                    [:long, :long, :pointer, :pointer, :long, :string, :pointer, :pointer], :void

    # MQGET (Hconn, Hobj, &MsgDesc, &GetMsgOpts, BufferLength, Buffer, &DataLength, &CompCode, &Reason)
    attach_function :mqget, :MQGET,
                    [:long, :long, :pointer, :pointer, :long, :pointer, :pointer, :pointer, :pointer], :void

    # MQOPEN (Hconn, &ObjDesc, Options, &Hobj, &CompCode, &Reason)
    attach_function :mqopen, :MQOPEN,
                    [:long, :pointer, :long, :pointer, :pointer, :pointer], :void

    # MQCLOSE (Hconn, &Hobj, Options, &CompCode, &Reason)
    attach_function :mqclose, :MQCLOSE,
                    [:long, :pointer, :long, :pointer, :pointer], :void

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

    # mqInquireInteger (Bag, Selector, ItemIndex, &ItemValue, &CompCode, &Reason);
    attach_function :mqai_inquire_integer, :mqInquireInteger,
                    [:long, :long, :long, :pointer, :pointer, :pointer], :void

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
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire string from attributes bag" if completion_code_ptr.read_long != MQCC_OK

      string_ptr.read_string.strip
    end

    def inquire_integer(bag_handle, selector, item_index)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long
      item_value_ptr = FFI::MemoryPointer.new :long

      mqai_inquire_integer(bag_handle, selector, item_index, item_value_ptr, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot inquire integer from attributes bag" if completion_code_ptr.read_long != MQCC_OK

      item_value_ptr.read_long
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

    def open_queue(connection_handle, queue_name, options)
      object_descriptor = MQClient::ObjectDescriptor.new
      object_descriptor[:StrucId] = MQClient::ObjectDescriptor::MQOD_STRUC_ID
      object_descriptor[:Version] = MQClient::ObjectDescriptor::MQOD_VERSION_1
      object_descriptor[:ObjectType] = MQClient::ObjectDescriptor::MQOT_Q
      object_descriptor[:ObjectName] = queue_name

      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long
      queue_handle_ptr = FFI::MemoryPointer.new :long

      mqopen(connection_handle, object_descriptor, options, queue_handle_ptr,
        completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot open queue" if completion_code_ptr.read_long != MQCC_OK

      queue_handle_ptr.read_long
    end

    def close_queue(connection_handle, queue_handle, options)
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      queue_handle_ptr = FFI::MemoryPointer.new :long
      queue_handle_ptr.write_long(queue_handle)

      mqclose(connection_handle, queue_handle_ptr, options, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot close queue" if completion_code_ptr.read_long != MQCC_OK
    end

    def put_message_on_queue(connection_handle, queue_handle, payload, reply_queue_name = "")
      message_options = MQClient::PutMessageOptions.new
      message_options[:StrucId] = MQClient::PutMessageOptions::MQPMO_STRUC_ID
      message_options[:Version] = MQClient::PutMessageOptions::MQPMO_VERSION_1

      message_descriptor = MQClient::MessageDescriptor.new
      message_descriptor[:StrucId] = MQClient::MessageDescriptor::MQMD_STRUC_ID
      message_descriptor[:Version] = MQClient::MessageDescriptor::MQMD_VERSION_1
      message_descriptor[:Expiry] = MQClient::MessageDescriptor::MQEI_UNLIMITED
      message_descriptor[:Report] = MQClient::MessageDescriptor::MQRO_NONE
      message_descriptor[:MsgType] = MQClient::MessageDescriptor::MQMT_DATAGRAM
      message_descriptor[:Priority] = 1
      message_descriptor[:Persistence] = MQClient::MessageDescriptor::MQPER_PERSISTENT
      message_descriptor[:ReplyToQ] = reply_queue_name

      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long

      mqput(connection_handle, queue_handle, message_descriptor, message_options, payload.length, payload, completion_code_ptr, reason_code_ptr)
      raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot send message" if completion_code_ptr.read_long != MQCC_OK

      message_descriptor[:MsgId]
    end

    def queue_depth(connection_handle, queue_name)
      adminbag_handle = create_admin_bag
      responsebag_handle = create_response_bag

      add_string_to_bag(adminbag_handle, MQCA_Q_NAME, queue_name)
      add_integer_to_bag(adminbag_handle, MQIA_Q_TYPE, MQQT_LOCAL)
      add_inquiry(adminbag_handle, MQIA_CURRENT_Q_DEPTH)

      execute(connection_handle, MQCMD_INQUIRE_Q, MQHB_NONE, adminbag_handle, responsebag_handle, MQHO_NONE, MQHO_NONE)

      attributes_bag_handle = inquire_bag(responsebag_handle, MQHA_BAG_HANDLE, 0)
      queue_depth = inquire_integer(attributes_bag_handle, MQIA_CURRENT_Q_DEPTH, 0)

      delete_bag(adminbag_handle)
      delete_bag(responsebag_handle)

      queue_depth
    end

    def get_message_from_queue(connection_handle, queue_handle, options = {})
      completion_code_ptr = FFI::MemoryPointer.new :long
      reason_code_ptr = FFI::MemoryPointer.new :long
      data_length_ptr = FFI::MemoryPointer.new :long

      message_options = prepare_get_message_options(false, options)
      message_descriptor = prepare_get_message_descriptor(options)

      data_length = 8 * 1024
      buffer_ptr = FFI::MemoryPointer.new :char, data_length

      mqget(connection_handle, queue_handle, message_descriptor, message_options, data_length, buffer_ptr, data_length_ptr, completion_code_ptr, reason_code_ptr)

      if (completion_code_ptr.read_long == MQCC_WARNING && reason_code_ptr.read_long == MQRC_TRUNCATED_MSG_FAILED)
          msg_id = message_descriptor[:MsgId]
          data_length = data_length_ptr.read_long
          buffer_ptr = FFI::MemoryPointer.new :char, data_length
          message_descriptor = prepare_get_message_descriptor(msg_id)
          mqget(connection_handle, queue_handle, message_descriptor, message_options, data_length, buffer_ptr, data_length_ptr, completion_code_ptr, reason_code_ptr)
          raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot read message again after learning message length" if completion_code_ptr.read_long == MQCC_FAILED
      else
        raise RMQException.new(completion_code_ptr.read_long, reason_code_ptr.read_long), "Cannot learn message length" unless completion_code_ptr.read_long == MQCC_OK
      end

      RMQ::Message.new(buffer_ptr.read_string, message_descriptor)
    end

    def print_msg_id(msg_id)
      hex_string = ''
      for i in (0..MQClient::MessageDescriptor::MSG_ID_LENGTH-1) do
        hex_string << "0x#{msg_id[i].to_s(16)}"
        hex_string << ", " if i < MQClient::MessageDescriptor::MSG_ID_LENGTH-1
      end
      hex_string
    end

    private

    def prepare_get_message_options(accept_truncated_msg, options = {})
      message_options = GetMessageOptions.new
      message_options[:StrucId] = GetMessageOptions::MQGMO_STRUC_ID
      message_options[:Version] = GetMessageOptions::MQGMO_VERSION_1
      message_options[:Options] = 0

      if accept_truncated_msg
        message_options[:Options] = GetMessageOptions::MQGMO_ACCEPT_TRUNCATED_MSG | message_options[:Options]
      end

      if options.has_key?(:timeout)
        message_options[:Options] = GetMessageOptions::MQGMO_WAIT | message_options[:Options]
        message_options[:WaitInterval] = options[:timeout] * 1000
      end

      message_options
    end

    def prepare_get_message_descriptor(options)
      message_descriptor = MQClient::MessageDescriptor.new
      message_descriptor[:StrucId] = MQClient::MessageDescriptor::MQMD_STRUC_ID
      message_descriptor[:Version] = MQClient::MessageDescriptor::MQMD_VERSION_1

      if options.has_key?(:message_id)
        msg_id = options[:message_id]
        for i in (0..MQClient::MessageDescriptor::MSG_ID_LENGTH-1) do
          message_descriptor[:MsgId][i] = msg_id[i].nil? ? 0 : msg_id[i]
        end
      end

      message_descriptor
    end

  end
end
