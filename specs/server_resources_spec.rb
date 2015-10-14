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
      expect(test_server.fetch_response_body(200, "/test_file")).to include("<html>")
    end

    it "should return the auto-generated 404 body if the resource doesn't exist" do
      expect(test_server.fetch_response_body(404, "/non_existent_resource")).to include("<h1> Resource Not Found</h1>")
    end

  end

  context "build_response_header" do

    it "should return the correct 'Content-Length' with the 200 response" do
      test_contents = "These are the test contents"
      expect(test_server.build_response_header(200, test_contents)).to include("Content-Length: #{test_contents.length}")
    end

    it "should return the correctly formatted 404 header if no existing resource" do
      contents_404 = test_server.fetch_response_body(404, "/non_existent_resource")
      expect(test_server.build_response_header(404, contents_404)).to include("HTTP/1.1 404 REQUEST NOT FOUND")
    end

  context "adding query fields" do
    it "should correctly add the first and last name to the welcome screen" do
      ## have to normalize resource = "/welcome?first=Burt&last=Malkiel"
      response_body = test_server.fetch_response_body(200, )
      response_body = test_server.add_query_to_response_body(response_body, "/welcome")
      expect(response_body). to include("Burt Malkiel!")
    end
  end

  end


 context "form entire response" do
   it "should return a properly formatted response" do
     open("sinatra_server/views/test_file.html", "w+") do |f|
       f << "<html>\n"
       f << "\t<p>This is a test</p>\n"
       f << "</html>"
     end
     response_body = test_server.fetch_response_body(200, "/test_file")
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
