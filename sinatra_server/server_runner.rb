require 'socket'
require_relative 'server_resources.rb'

#accept the connection
#parse the HTTP request
#fetch the necessary resources
#return resources as the response



connection = TCPServer.new("127.0.0.1", 2000)
server = HTTPServer.new

# full request and response cycle
loop do
  # get client
  client = connection.accept

# had to get each line of header, did it with this messy "break" method--has to be a better way!
  request_header = ""
  client.each_line do |line|
    request_header << line
    break if line == "\r\n"
  end

  # fetch the resource(s) and determine code
  resource = server.normalize_resource(server.get_base_http_resource(request_header))
  response_code = server.determine_response_code(resource)
  # get full resource to retrieve any query strings
  full_resource = server.get_full_http_resource(request_header)

  # build the body
  response_body = server.build_response_body(response_code, resource)
  finalized_response_body = server.aggregate_response_body(response_body,resource, full_resource)

  # build header
  response_header = server.build_response_header(response_code, response_body)
  finalized_response_header = server.aggregate_response_header(request_header, response_header)

  # send it to the client
  client.puts(server.form_entire_response(finalized_response_header, finalized_response_body))
  client.close
end
