module RMQ
  class Message
    attr_reader :payload

    def initialize(payload, message_descriptor)
      @payload = payload
      @message_descriptor = message_descriptor
    end

    def reply_queue_name
      @message_descriptor[:ReplyToQ].to_s.strip
    end

    def message_id
      @message_descriptor[:MsgId]
    end

  end
end