require_relative "../sinatra_server/server_resources.rb"



describe "HTTPServer" do
  let(:test_server){HTTPServer.new}

  before :all do
    File.new("sinatra_server/views/test_file.html", "w+")
  end


  context "determine_response_header" do

    it "should return a 200 if the resource exists" do
      expect(test_server.determine_response_header("/test_file")).to eq(200)
    end

    it "should return a 404 if the resource doesn't exist" do
      expect(test_server.determine_response_header("/non_existent_file")).to eq(404)
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
      contents_404 = test_server.build_response_body(404, "non_existent_resource")
      expect(test_server.build_response_header(404, contents_404)).to include("HTTP/1.1 404 REQUEST NOT FOUND")
    end

  end



  after :all do
    File.delete("sinatra_server/views/test_file.html")
  end

end
