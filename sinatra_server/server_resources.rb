require 'socket'
require_relative "server_helpers.rb"




class HTTPServer

  @@root_path = Dir.getwd
  @@views_path = "#{@@root_path}/sinatra_server/views"

  include ServerHelpers

  def determine_response_code(resource)
    if File.file?("#{@@root_path}/sinatra_server/views#{normalize_resource(resource)}")
      200
    else
      404
    end
  end


  def fetch_response_body(http_code, resource)
    if http_code == 200
      response_body = open("#{@@views_path}#{normalize_resource(resource)}", "r")
    elsif http_code == 404
      response_body = open("#{@@views_path}/404.html", "r")
    end
    response_body.read
  end

  # def build_response_body(fetched_response_body, resource)
  #   # TO DO: Know it's good practice to close the file after, don't know how here since I need to return the file.  Think it's OK for now.
  #   finalized_response_body = ""
  #   response_body.each_line do |line|
  #     finalized_response_body << line
  #   end
  #   finalized_response_body
  # end



  def add_query_to_response_body(response_body, resource)
    if resource == "/welcome" && query_parameters?(resource)
      full_name = parse_name_query_parameters(resource)
      insert_welcome_parameters(finalized_response_body, full_name)
    end
  end


  def build_response_header(http_code, response_body)
    case http_code
    when 200
      response_header =
<<-HEADER
HTTP/1.1 200 OK
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: #{response_body.length}
Connection: close
HEADER
    when 404
      response_header = <<-HEADER
HTTP/1.1 404 REQUEST NOT FOUND
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: #{response_body.length}
Connection: close
HEADER
    end
  end

  def form_entire_response(response_header, response_body)
  <<-RESPONSE
#{response_header}
#{response_body}
  RESPONSE
  end


end



# test = HTTPServer.new
# test.build_response_body(200, "/welcome")
# puts test.build_response_header(body, 200)
