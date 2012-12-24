require 'rubygems'
require 'ffi-rzmq'

#
# Inspired by the lazy-pirate pattern
# http://zguide.zeromq.org/rb:lpclient
#


require 'rubygems'
require 'ffi-rzmq'

class RoundtripZMQClient
  def initialize(host, opts={})
    @host = host
    @timeout = opts[:timeout] || 500 #500ms
    @retries = opts[:retries] || 3
    @ctx = ZMQ::Context.new(1)
    reconnect
  end

  def close
    @poller.deregister(@socket, ZMQ::POLLIN)
    @socket.close
  end

  def reconnect
     @socket = @ctx.socket(ZMQ::REQ)
     @socket.setsockopt(ZMQ::LINGER, 0)
     @socket.connect(@host)
     @poller = ZMQ::Poller.new
     @poller.register(@socket, ZMQ::POLLIN)
  end

  def send(message)
    raise("Send: #{message} failed") unless @socket.send_string(message)
    @retries.times do 
      if @poller.poll(@timeout) > 0
        s = ''
        @socket.recv_string s
        yield s
        return
      else
        close
        reconnect
      end
    end
    raise 'Server down'
  end
end

if $0 == __FILE__
    connection = RoundtripZMQClient.new("tcp://localhost:5160")
    begin
      connection.send(ARGV.join(' ')) do |reply|
        puts(reply)
      end
    ensure
      connection.close
    end
end

