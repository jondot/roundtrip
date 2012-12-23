require 'roundtrip'
require 'ffi-rzmq'
require 'json'


class Roundtrip::Raw
  def initialize(core, opts={})
    @core = core
    @debug = opts[:debug] || true
  end

  #
  # quick protocol desc:
  #
  # S metric.name.foo i-have-an-id-optional
  #
  # U metric.name.foo checkpoint.name
  #
  # E metric.name.foo
  #
  # All replies are serialized JSON
  #

  ACTIONS = { "S" => :start, "U" => :checkpoint, "E" => :end }
  def listen!(port)
    context = ZMQ::Context.new(1)

    puts "Roundtrip listening with a zeromq socket on port #{port}..."
    socket = context.socket(ZMQ::REP)
    socket.bind("tcp://*:#{port}")

    while true do
      select(socket)
    end
  end

  def select(socket)
    request = ''
    rc = socket.recv_string(request)

    # poor man's RPC

    unless request && request.length > 2
      socket.send_string({:error => "bad protocol: [#{request}]"}.to_json)
      return
    end
    action, params = ACTIONS[request[0]], request[1..-1].strip.split(/\s+/)

    begin
      resp = @core.send(action, *params)
      socket.send_string(resp.to_json)
    rescue
      puts "error: #{$!}" if @debug
      socket.send_string({ :error => $! }.to_json)
    end
  end
end

