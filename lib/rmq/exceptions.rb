module RMQ
  class RMQException < RuntimeError
    attr_reader :reason_code
    attr_reader :completion_code

    def initialize(completion_code, reason_code)
      @reason_code = reason_code
      @completion_code = completion_code
    end
  end
end
