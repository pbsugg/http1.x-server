require 'cgi'
require 'csv'
require_relative 'server_resources.rb'
module ServerHelpers


#Methods to process the request header

  # GET, POST, etc.
  def get_http_verb(request_header)
    http_verb = /^[A-Z]*/.match(request_header).to_s
  end

  # just the base uri that allows me to find the files
  def get_base_http_resource(request_header)
    base_http_resource = /\/[^?|\s]*/.match(request_header)[0]
  end

  # uri that includes query strings
  def get_full_http_resource(request_header)
    full_http_resource = /\/[^\s]*/.match(request_header)[0]
  end


  def query_parameters?(resource)
    resource.include?("?")
  end

  def parse_name_query_parameters(resource)
    if resource.include?("?first")
      query = /first[^\s]*/.match(resource)[0]
      full_name = CGI::parse(query)
      "#{full_name["first"].pop} #{full_name["last"].pop}!"
    end
  end

  # login

  def parse_login_info(request_header)
    username = /(?<=username=)\w*/.match(request_header)[0]
    password = /(?<=password=)\w*/.match(request_header)[0]
    {username: username, password: password}
  end

  # find user from '.csv' db file
  def authenticate_user(login_info)
    CSV.foreach("#{Dir.pwd}/db/users.csv") do |line|
      potential_username = line[0]
      potential_password = line[1]
      if login_info[:username] == potential_username
        return true if login_info[:password] == potential_password
      end
    end
  end
  # users

  def create_new_user
  end


  # Methods to get the resource

  def normalize_resource(resource)
    if resource.include?(".html")
      resource
    else
      resource + ".html"
    end
  end

# dealing with the body

  # insert point = text to replace
  #text_to_insert = what you want to add
  def insert_to_body(params = {})
    params[:response_body].gsub!(/(#{params[:insert_point]})/, "#{params[:text_to_insert]}" )
  end

  # create a resource called /visits
  # assign everyone who connects a uniquely identified cookie
  # When you go to /visits, if that person has a cookie that the server recognizes, increment the visit count


  # cookie methods--checking the header

  def visit_cookie?(request_header)
    request_header.include?("visit-count")
  end

  def create_visit_cookie
<<-EOF
Set-Cookie: visit-count=1
EOF
  end

  # gets the number of visits in string form
  def get_visit_count(request_header)
    /(?<=visit-count=)\d*/.match(request_header)[0].to_i
  end

  # updates the visitor count by one
  def add_to_visit_count(request_header)
    visit_count = /(?<=visit-count=)\d*/.match(request_header)[0].to_i
    visit_count += 1
    "Set-Cookie: visit-count=#{visit_count}"
  end

  #unique user id

  def create_uid_cookie
    require 'securerandom'
    user_id = SecureRandom.uuid
    "Set-Cookie: uid=#{user_id}"
  end

  def find_uid(request_header)
    uid = /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/.match(request_header)[0]
  end

  # header methods

  # This test is bad at the moment, causing problems with format of header
  def insert_to_header(header, line_to_insert)
    # always inserting immediately before the last line
    index_to_insert = header.index(/Connection: close/)
    revised_header = header.insert(index_to_insert, "#{line_to_insert}\r\n")
  end

end
