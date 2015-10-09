require_relative "../sinatra_server/server_controller.rb"



describe "HTTPServer" do
  let(:test_server){HTTPServer.new}
  let(:test_resource_file){File.new("sinatra_server/views/test_file.html", "w+")}


  context "determine_response_header" do

    it "should return a 200 if the resource exists" do
      expect(test_server.determine_response_header("sinatra_server/views/test_file")).to eq(200)
    end

    it "should return a 404 if the resource doesn't exist"

  end

  context "build_response_header" do

    it "should return the correct 'Content-Length' with the 200 response"

    it "should return the correctly formatted 404 response if no existing resource"

  end

  context "serve_response_body" do

    before :each do
      test_resource_file.write("<html></html>")
      test_resource_file.read
    end

    it "should be able to return the contents of a new html file" do


      expect(test_server.serve_response_body("sinatra_server/views/test_file.html")).to include("<html>")
    end



  end

  after :all do
    File.delete("sinatra_server/views/test_file.html")
  end

end
