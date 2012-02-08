

module MQClient
  extend FFI::Library

  ffi_lib "C:\\Program Files (x86)\\IBM\\WebSphere MQ\\bin\\mqic32.dll"
  ffi_convention :stdcall

  # MQCONN (QMgrName, Hconn, CompCode, Reason)
  attach_function :mqconn, :MQCONN,
                  [:string, :pointer, :pointer, :pointer], :void
  attach_function :mqdisc, :MQDISC,
                  [:pointer, :pointer, :pointer], :void

end