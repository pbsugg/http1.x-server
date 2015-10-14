require 'cgi'

module ServerHelpers

  def get_http_verb(request_header)
    http_verb = /^[A-Z]*/.match(request_header).to_s
  end

  def get_http_resource(request_header)
    http_resource = /\/[^?|\s]*/.match(request_header)[0]
  end

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

  def parse_name_query_parameters(request_header)
    if request_header.include?("?first")
      query = /first[^\s]*/.match(request_header)[0]
      CGI::parse(query)
    end
  end

  def insert_welcome_parameters(finalized_response_body, full_name = {})
    finalized_response_body.gsub!(/(World)/, "#{full_name["first"].pop} #{full_name["last"].pop}!" )
    finalized_response_body
  end


end
