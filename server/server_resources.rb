require 'socket'
require_relative "./server_helpers.rb"




class HTTPServer

  include ServerHelpers

  @@root_path = File.dirname(__FILE__)
  @@views_path = "#{@@root_path}/views"

  def initialize
    @current_users = []
    @unlogged_info = []
  end

  # login tracker methods

  def log_in_user(login_info, uid)
    p user = [login_info[:username], uid]
    @current_users << user
  end

  def is_logged_in?(request_header)
    p find_uid(request_header)
    if find_uid(request_header)
      @current_users.each do |user|
        # user[1] is the uid in the session store
        p user[1]
        return true if user[1] == find_uid(request_header)
      end
    end
    false
  end

  def register_unlogged_info
    @unlogged_info << @current_users[-1]
  end

  # TD: for inserting an existing uid from session to header
  def insert_unlogged_uid
    "Set-Cookie: uid=#{@unlogged_info[0][1]}"
  end

  def delete_unlogged_info
    @unlogged_info = []
  end

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
 # don't like the fact that this is take four arguments either, obv. doing too much
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
    elsif resource == "/login.html"  && get_http_verb(request_header) == "POST"
      p "here in controller!"
      login_info = parse_login_info(request_header)
      p login_info
      if authenticate_user(login_info)

        register_unlogged_info

        # p "user found!"
        # once user logs in...
          # (1) register him/header in my instance variable
          # (2) find/give a cookie
        response_body = build_response_body(200, "/profile.html")
      else
        p "user not found!"
        # response_body = build_response_body(404, "/404.html")
      end
    elsif resource == "/registration.html"  && get_http_verb(request_header) == "POST"
      login_info = parse_login_info(request_header)
      p login_info
      # p @current_users
      response_body = build_response_body(200, "/profile.html")
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
<>
HEADER
    when 404
      response_header = <<-HEADER
HTTP/1.1 404 REQUEST NOT FOUND
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: #{response_body.length}
Connection: close
<>
HEADER
    end
  end

# are there any users?

# this method has become a mess, needs more work
  def aggregate_response_header(request_header, response_header)
      if @unlogged_info.any?
        p "here at unlogged info: #{@unlogged_info}"
        p insert_unlogged_uid
        insert_to_header(response_header, insert_unlogged_uid)
      elsif no_visit_cookie?(request_header)
        insert_to_header(response_header, create_visit_cookie)
      else
        insert_to_header(response_header, add_to_visit_count(request_header))
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
