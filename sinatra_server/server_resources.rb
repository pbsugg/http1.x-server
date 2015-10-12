require 'socket'
require_relative "server_helpers.rb"




class HTTPServer

  @@root_path = Dir.getwd
  @@views_path = "#{@@root_path}/sinatra_server/views"

  include ServerHelpers

  #   case input
  #   when "GET /welcome HTTP/1.1"
  #   client.puts <<-WELCOME
  # HTTP/1.1 200 OK
  # Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
  # Content-Type: text/html
  # Content-Length: 198
  # Connection: close
  #
  # <html>
  # <head>
  #   <title>Welcome</title>
  # </head>
  # <body>
  #   <h1>Hello World</h1>
  #   <p>Welcome to the world's simplest web server.</p>
  #   <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>
  # </body>
  # </html>
  # WELCOME
  #   when "GET /profile HTTP/1.1"
  #     client.puts <<-PROFILE
  # HTTP/1.1 200 OK
  # Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
  # Content-Type: text/html
  # Content-Length: 112
  # Connection: close
  #
  # <html>
  # <head>
  #   <title>My Profile Page</title>
  # </head>
  # <body>
  #   <p>This is my profile page.</p>
  # </body>
  # </html>
  # PROFILE
  #   else
  #     client.puts <<-404
  # HTTP/1.1 404 REQUEST NOT FOUND
  # 404
    #   end
  # client.close
  # end





  def determine_response_code(resource)
    if File.file?("#{@@root_path}/sinatra_server/views#{normalize_resource(resource)}")
      200
    else
      404
    end
  end


  def build_response_body(http_code, resource)
    if http_code == 200
      response_body = open("#{@@views_path}#{normalize_resource(resource)}", "r")
    elsif http_code == 404
      response_body = open("#{@@views_path}/404.html", "r")
    end
    # TO DO: Know it's good practice to close the file after, don't know how here since I need to return the file.  Think it's OK for now.
    finalized_response_body = ""
    response_body.each_line do |line|
      finalized_response_body << line
    end
    finalized_response_body
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

test = HTTPServer.new
test.build_response_body(200, "/welcome")
# puts test.build_response_header(body, 200)
