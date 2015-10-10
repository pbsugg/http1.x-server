require 'socket'
require_relative 'server_resources.rb'
require_relative 'server_helpers.rb'


#accept the connection
#parse the HTTP request
#fetch the necessary resources
#return resources as the response


socket = TCPServer.new("127.0.0.1", 2000)
server = HTTPServer.new
loop do
  client = socket.accept
  input = client.gets.chomp
  client.close
end
