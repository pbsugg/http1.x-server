require_relative "../sinatra_server/server_resources.rb"


describe "HTTPServer" do
  let(:test_server){HTTPServer.new}

  before :all do
    File.new("sinatra_server/views/test_file.html", "w+")
  end


  context "determine_response_code" do

    it "should return a 200 if the resource exists" do
      expect(test_server.determine_response_code("/test_file")).to eq(200)
    end

    it "should return a 404 if the resource doesn't exist" do
      expect(test_server.determine_response_code("/non_existent_file")).to eq(404)
    end

  end

  context "build_response_body" do


    it "should be able to return the contents of a new html file" do
      open("sinatra_server/views/test_file.html", "r+") do |f|
        f << "<html></html>"
      end
      expect(test_server.build_response_body(200, "/test_file")).to include("<html>")
    end

    it "should return the auto-generated 404 body if the resource doesn't exist" do
      expect(test_server.build_response_body(404, "/non_existent_resource")).to include("<h1> Resource Not Found</h1>")
    end

  end

  context "build_response_header" do

    it "should return the correct 'Content-Length' with the 200 response" do
      test_contents = "These are the test contents"
      expect(test_server.build_response_header(200, test_contents)).to include("Content-Length: #{test_contents.length}")
    end

    it "should return the correctly formatted 404 header if no existing resource" do
      contents_404 = test_server.build_response_body(404, "/non_existent_resource")
      expect(test_server.build_response_header(404, contents_404)).to include("HTTP/1.1 404 REQUEST NOT FOUND")
    end

  end

  contexts "cookies" do
    
  end

    it "should be able to find the /visits page"

    it "should give a cookie to the end-user on the /visits page"

    it "should add up all visits for a user with a given cookie"

    it "should not count someone with a different cookie toward visits"

  end

  context "adding query fields" do
    let(:query_parameter_header){"GET /welcome?first=Phil&last=Sugg HTTP/1.1"}
    let(:welcome_file){File.open("sinatra_server/views/welcome.html", "r").read}

    it "should correctly add the first and last name to the welcome screen" do
      # p welcome_file
      full_http_resource = test_server.get_full_http_resource(query_parameter_header)
      response_body = test_server.add_query_to_response_body(welcome_file, full_http_resource)
      expect(response_body).to include("Phil Sugg!")
    end

  end




 context "form entire response" do
   it "should return a properly formatted response" do
     open("sinatra_server/views/test_file.html", "w+") do |f|
       f << "<html>\n"
       f << "\t<p>This is a test</p>\n"
       f << "</html>"
     end
     response_body = test_server.build_response_body(200, "/test_file")
     response_header =  test_server.build_response_header(200, response_body)
     expect(test_server.form_entire_response(response_header, response_body)). to eq(
<<-EOS
HTTP/1.1 200 OK
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: 37
Connection: close

<html>
\t<p>This is a test</p>
</html>
EOS
    )
   end
 end


  after :all do
    File.delete("sinatra_server/views/test_file.html")
  end

end
