module RMQ
  module MQClient

    class MessageDescriptor < FFI::Struct
      MQMD_STRUC_ID         = "MD  "
      MQMD_VERSION_1        = 1
      MQEI_UNLIMITED        = -1
      MQRO_NONE             = 0x00000000
      MQMT_DATAGRAM         = 8
      MQPER_PERSISTENT      = 1

      layout  :StrucId, [:char, 4],
        :Version, :long,
        :Report, :long,
        :MsgType, :long,
        :Expiry, :long,
        :Feedback, :long,
        :Encoding, :long,
        :CodedCharSetId, :long,
        :Format, [:char, 8],
        :Priority, :long,
        :Persistence, :long,
        :MsgId, [:char, 24],
        :CorrelId, [:char, 24],
        :ReplyToQ, [:char, 48],
        :ReplyToQMgr, [:char, 48],
        :UserIdentifier, [:char, 12],
        :AccountingToken, [:char, 32],
        :ApplIdentityData, [:char, 32],
        :PutApplType, :long,
        :PutApplName, [:char, 28],
        :PutDate, [:char, 8],
        :PutTime, [:char, 8],
        :ApplOriginData, [:char, 4],
        :GroupId, [:char, 24],
        :MsgSeqNumber, :long,
        :Offset, :long,
        :MsgFlags, :long,
        :OriginalLength, :long
    end

  end
end
