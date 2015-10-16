require 'cgi'

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

  # Methods to get the resource

  def normalize_resource(resource)
    if resource.include?(".html")
      resource
    else
      resource + ".html"
    end
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

  # insert point = text to replace
  #text_to_insert = what you want to add
  def insert_to_body(params = {})
    params[:response_body].gsub!(/(#{params[:insert_point]})/, "#{params[:text_to_insert]}" )
  end

  # create a resource called /visits
  # assign everyone who connects a uniquely identified cookie
  # When you go to /visits, if that person has a cookie that the server recognizes, increment the visit count


  # cookie methods

  def find_uid_cookie(request_header)
    if request_header.include?("Cookie:")
      /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/.match(request_header)[0]
    end
  end

  def create_uid_cookie
    require "securerandom"
    "Set-Cookie: uid=#{SecureRandom.uuid}; Expires=Wed, 09 Jun 2021 10:18:14 GMT\n"
  end

  # header methods

  def insert_to_header(header, line_to_insert)
    # always inserting immediately before the last line
    index_to_insert = header.index(/Connection: close/)
    revised_header = header.insert(index_to_insert, "#{line_to_insert}")
  end





end
