require_relative "../sinatra_server/server_controller.rb"

describe "HTTPServer" do
    let(:test_server){HTTPServer.new}

  describe "serve_response_body" do

    it "should be able to return the contents of a new html file" do
      expect(test_server.serve_response_body("")).to exist
    end

  end



end
