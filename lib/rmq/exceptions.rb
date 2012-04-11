module RMQ
  class RMQException < RuntimeError
    include Constants

    attr_reader :reason_code
    attr_reader :completion_code

    def initialize(completion_code, reason_code)
      @reason_code = reason_code
      @completion_code = completion_code
    end

    def message
      "#{to_s}. Reason code = #{decode_reason_code(reason_code)} (#{reason_code}), completion code = #{decode_completion_code(completion_code)}"
    end
  end

  class RMQTimeOutError < RuntimeError
  end

  class RMQMessageNotFoundException < RuntimeError
    def initialize(message_id)
    end

    def message
      "Could not find message"
    end
  end

end
