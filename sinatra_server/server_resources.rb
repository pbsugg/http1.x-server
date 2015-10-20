require 'socket'
require_relative "server_helpers.rb"




class HTTPServer

  @@root_path = File.dirname(__FILE__)
  @@views_path = "#{@@root_path}/views"

  include ServerHelpers

# Response pre-processing

  def determine_response_code(resource)
    if File.file?("#{@@root_path}/views#{normalize_resource(resource)}")
      200
    else
      404
    end
  end

#Response body methods

  def build_response_body(http_code, resource)
    case http_code
    when 200
      response_body = open("#{@@views_path}#{normalize_resource(resource)}", "r")
    when 404
      response_body = open("#{@@views_path}/404.html", "r")
    end
    response_body.read
  end


 #todo: something smells about this method still, it does/knows too much
 # don't like the fact that this is take three arguments either, obv. doing too much
  def aggregate_response_body(request_header, response_body, resource, full_resource)
    # welcome page
    if resource == "/welcome.html" && query_parameters?(full_resource)
      full_name = parse_name_query_parameters(full_resource)
      insert_to_body({response_body: response_body, insert_point: "World", text_to_insert: full_name})
    # visits page
  elsif resource == "/visits.html"
    # this is bad, should be a method I know...
      count = get_visit_count(request_header).to_i
      count +=1
      insert_to_body({response_body: response_body, insert_point: "X", text_to_insert: "#{count}"})
    else
      response_body
    end
  end

# Response header methods

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


  def aggregate_response_header(request_header, response_header)
     if visit_cookie?(request_header)
       add_to_visit_count(request_header, response_header)
     else
       insert_to_header(response_header, create_visit_cookie)
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
