require 'ffi-rzmq'

context = ZMQ::Context.new(1)

socket = context.socket(ZMQ::REQ)
socket.connect("tcp://localhost:5160")
bucket = ''
socket.send_string(ARGV.join(' '))
socket.recv_string(bucket)

puts bucket
