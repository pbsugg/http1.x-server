# TO DO--not the file b/c it would create a prot conflict.
# Instead I just create two files on the same port
# Have to start the runner before starting this spec test
# require_relative "../sinatra_server/server_runner.rb"
# require_relative 'spec_helper.rb'
require 'net/http'

describe "runner file" do

  let(:sample_welcome_uri){URI('http://127.0.0.1:2000/welcome')}
  let(:successful_http_get){Net::HTTP.get(sample_welcome_uri)}
  let(:bad_uri){URI('http://127.0.0.1:2000/no_one_home')}
  let(:unsuccessful_http_get){Net::HTTP.get(bad_uri)}
  let(:visit_get){Net::HTTP.get(URI('http://127.0.0.1:2000/visits'))}

  it "should correctly fetch a resource that exists" do
    expect(successful_http_get).to eq("<html>\n<head>\n  <title>Welcome</title>\n</head>\n<body>\n  <h1>Hello World</h1>\n  <p>Welcome to the world's simplest web server.</p>\n  <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>\n</body>\n</html>\n")
  end

  it "should return the correct 404 for a resource that doesn't exist" do
    expect(unsuccessful_http_get).to eq("<html>\n<h1> Resource Not Found</h1>\n</html>\n")
  end

  it "should correctly parse the query parameters and insert them into the welcome page" do
    expect(successful_http_get).to include("Phil Sugg")
  end

  context "cookie" do


    # This won't work b/c the cookie is in the header, isn't picked up by the browser display!

    # it "should give a cookie to the end-user on the /visits page" do
    #   expect(successful_http_get).to include("Set-Cookie")
    # end

    it "should add up all visits for a user with a given cookie" do
      3.times {visit_get}
      expect(visit_get).to include("4")
    end

    it "should not count someone with a different cookie toward visits"

  end

end
