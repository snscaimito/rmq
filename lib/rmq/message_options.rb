module RMQ
  module MQClient

    class MessageOptions < FFI::Struct
      MQPMO_STRUC_ID    = "PMO "
      MQPMO_VERSION_1   = 1
      MQPMO_SYNCPOINT   = 0x00000002

      layout  :StrucId, [:char, 4],
        :Version, :long,
        :Options, :long,
        :Timeout, :long,
        :Context, :long,
        :KnownDestCount, :long,
        :UnknownDestCount, :long,
        :InvalidDestCount, :long,
        :ResolvedQName, [:char, 48],
        :ResolvedQMgrName, [:char, 48],
        :RecsPresent, :long,
        :PutMsgRecFields, :long,
        :PutMsgRecOffset, :long,
        :ResponseRecOffset, :long,
        :PutMsgRecPtr, :pointer,
        :ResponseRecPtr, :pointer,
        :OriginalMsgHandle, :int64,
        :NewMsgHandle, :int64,
        :Action, :long,
        :PubLevel, :long
    end
  end
end
