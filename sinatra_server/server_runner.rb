require 'socket'
require_relative 'server_resources.rb'


#accept the connection
#parse the HTTP request
#fetch the necessary resources
#return resources as the response



connection = TCPServer.new("127.0.0.1", 2000)
server = HTTPServer.new

loop do
  client = connection.accept
  request_header = client.gets.chomp
  resource = server.normalize_resource(server.get_http_resource(request_header))
  response_code = server.determine_response_code(resource)
  response_body = server.build_response_body(response_code, resource)
  response_header = server.build_response_header(response_code, response_body)
  client.puts(server.form_entire_response(response_header, response_body))
end
