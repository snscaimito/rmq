require 'rmq/mqclient'

class QueueManager
  include MQClient

  def self.connect(queue_manager)
    hconn_ptr = FFI::MemoryPointer.new :long
    completion_code_ptr = FFI::MemoryPointer.new :long
    reason_code_ptr = FFI::MemoryPointer.new :long

    MQClient.mqconn(queue_manager, hconn_ptr, completion_code_ptr, reason_code_ptr)

    @hconn = hconn_ptr.read_long
    completion_code = completion_code_ptr.read_long
    reason_code = reason_code_ptr.read_long

    puts "Hconn #{@hconn}"
    puts "completion #{completion_code}"
    puts "reason #{reason_code}"

    self
  end

end