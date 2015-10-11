require 'socket'
require_relative 'server_resources.rb'
require_relative 'server_helpers.rb'


#accept the connection
#parse the HTTP request
#fetch the necessary resources
#return resources as the response



connection = TCPServer.new("127.0.0.1", 2000)
server = HTTPServer.new

loop do
  client = connection.accept
  request_header = client.gets.chomp
  resource = normalize_resource(get_http_resource(request_header))
  response_code = determine_response_code(resource)
  response_body = build_response_body(response_code, resource)
  response_header = build_response_header(response_code, response_body)



end
