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
  p "Start of response cycle: Server waiting for a request"
  server.delete_unlogged_info
  # get client
  client = connection.accept
# had to get each line of header, did it with this messy "break" method--has to be a better way!
# Having problems receiving POST bodies--had to do this for now.
  request_header = ""
  client.each_line do |line|
    request_header << line
    p line
    if request_header.include?("POST")
      break if line.include?("password")
      break if line.include?("password")

    else
      break if line == "\r\n"
    end
    # almost seems like there are two response streams
    # had to use a *separate* break (so *two* breaks)
    # break if request_header.include?("password=")

  end

  p "Server receipt of request closed"
  puts "\n"
  p ">>>>>>>>>"
  p "Here is your http verb: #{server.get_http_verb(request_header)}"
  p "Here is your resource: #{server.get_full_http_resource(request_header)}"
  p ">>>>>>>>>"
  puts "\n"

  puts "now to process the request!"

  # fetch the resource(s) and determine code
  resource = server.normalize_resource(server.get_base_http_resource(request_header))
  response_code = server.determine_response_code(resource)
  # get full resource to retrieve any query strings
  full_resource = server.get_full_http_resource(request_header)

  # build the body
  response_body = server.build_response_body(response_code, resource)
  finalized_response_body = server.aggregate_response_body(request_header, response_body, resource, full_resource)

  # build header
  response_header = server.build_response_header(response_code, finalized_response_body)
  finalized_response_header = server.aggregate_response_header(request_header, response_header)

  # send it to the client
  client.puts(server.form_entire_response(finalized_response_header, finalized_response_body))
  client.close

end
