module ServerHelpers

  def get_http_verb(request_header)
    http_verb = /^[A-Z]*/.match(request_header).to_s
  end

  def get_http_resource(request_header)
    http_resource = /\/[\S]*/.match(request_header)[0]
  end

  def normalize_resource(resource)
    if resource.include?(".html")
      resource
    else
      resource + ".html"
    end
  end

  
end
