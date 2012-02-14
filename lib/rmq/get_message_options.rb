module RMQ
  module MQClient

    class GetMessageOptions < FFI::Struct
      MQGMO_STRUC_ID        = "GMO "
      MQGMO_VERSION_1       = 1
      
      # Get Message Options
      MQGMO_WAIT                     = 0x00000001
      MQGMO_NO_WAIT                  = 0x00000000
      MQGMO_SET_SIGNAL               = 0x00000008
      MQGMO_FAIL_IF_QUIESCING        = 0x00002000
      MQGMO_SYNCPOINT                = 0x00000002
      MQGMO_SYNCPOINT_IF_PERSISTENT  = 0x00001000
      MQGMO_NO_SYNCPOINT             = 0x00000004
      MQGMO_MARK_SKIP_BACKOUT        = 0x00000080
      MQGMO_BROWSE_FIRST             = 0x00000010
      MQGMO_BROWSE_NEXT              = 0x00000020
      MQGMO_BROWSE_MSG_UNDER_CURSOR  = 0x00000800
      MQGMO_MSG_UNDER_CURSOR         = 0x00000100
      MQGMO_LOCK                     = 0x00000200
      MQGMO_UNLOCK                   = 0x00000400
      MQGMO_ACCEPT_TRUNCATED_MSG     = 0x00000040
      MQGMO_CONVERT                  = 0x00004000
      MQGMO_LOGICAL_ORDER            = 0x00008000
      MQGMO_COMPLETE_MSG             = 0x00010000
      MQGMO_ALL_MSGS_AVAILABLE       = 0x00020000
      MQGMO_ALL_SEGMENTS_AVAILABLE   = 0x00040000
      MQGMO_MARK_BROWSE_HANDLE       = 0x00100000
      MQGMO_MARK_BROWSE_CO_OP        = 0x00200000
      MQGMO_UNMARK_BROWSE_CO_OP      = 0x00400000
      MQGMO_UNMARK_BROWSE_HANDLE     = 0x00800000
      MQGMO_UNMARKED_BROWSE_MSG      = 0x01000000
      MQGMO_PROPERTIES_FORCE_MQRFH2  = 0x02000000
      MQGMO_NO_PROPERTIES            = 0x04000000
      MQGMO_PROPERTIES_IN_HANDLE     = 0x08000000
      MQGMO_PROPERTIES_COMPATIBILITY = 0x10000000
      MQGMO_PROPERTIES_AS_Q_DEF      = 0x00000000
      MQGMO_NONE                     = 0x00000000
      
      layout :StrucId, [:char, 4],
        :Version, :long,
        :Options, :long,
        :WaitInterval, :long,
        :Signal1, :long,
        :Signal2, :long,
        :ResolvedQName, [:char, 48],
        :MatchOptions, :long,
        :GroupStatus, :char,
        :SegmentStatus, :char,
        :Segmentation, :char,
        :Reserved1, :char
    end
  end
end
