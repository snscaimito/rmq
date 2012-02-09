

module MQClient
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


end