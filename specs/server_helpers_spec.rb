require_relative "../sinatra_server/server_helpers.rb"

describe "ServerHelpers" do

  let(:test_class){Class.new{extend ServerHelpers}}

  context "normalize_resource" do

    it "should not correct a resource that has the '.html' extension" do
      request_header = "/sample.html"
      expect(test_class.normalize_resource(request_header)).to eq(request_header)
    end

    it "should correct a resource that has no '.html' extension" do
      request_header = "/sample"
      expect(test_class.normalize_resource(request_header)).to eq("/sample.html")
    end

  end

  context "http element extraction" do

    let(:simple_request_header){"GET /index.html HTTP/1.1"}
    let(:complex_request_header){"POST /index/users/3.html HTTP/1.1"}


    it "should get the correct http verb" do
      expect(test_class.get_http_verb(simple_request_header)).to eq("GET")
      expect(test_class.get_http_verb(complex_request_header)).to eq("POST")
    end

    it "should get a one-level deep resource" do
      expect(test_class.get_base_http_resource(simple_request_header)).to eq("/index.html")
    end

    it "should get an entire resource that is several levels deep" do
      expect(test_class.get_base_http_resource(complex_request_header)).to eq("/index/users/3.html")
    end

  end

    context "extract query parameters" do

      let(:query_parameter_header){"GET /welcome?first=Phil&last=Sugg HTTP/1.1"}
      let(:welcome_file){File.open("sinatra_server/views/welcome.html", "r").read}

      it 'should correctly extract the first and last name at the welcome screen' do
        expect(test_class.parse_name_query_parameters(query_parameter_header)).to eq("Phil Sugg!")
      end

      it 'should insert welcome parameters at the correct place in the body' do
        full_name = test_class.parse_name_query_parameters(query_parameter_header)
        expect(test_class.insert_to_body({response_body: welcome_file, insert_point: "World", text_to_insert: full_name})).to include("Phil Sugg!")
      end

    end

# still not sure how to format this test--can't get the regex to match

    context "insert to header" do
      let(:test_header){
  <<-EOS
  HTTP/1.1 200 OK
  Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
  Content-Type: text/html
  Content-Length: 37
  Connection: close
  EOS
  }

      it "should insert a line correctly into the test header" do
        sample_insert = "Test: This is a Test\n"
        expect(test_class.insert_to_header(test_header, sample_insert)).to match(
  <<-EOS
  HTTP/1.1 200 OK
  Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
  Content-Type: text/html
  Content-Length: 37
  Test: This is a Test
  Connection: close
  EOS
        )
      end

    end


    context "cookies" do

      it "should create a cookie" do
        expect(test_class.create_uid_cookie).to match(/Set-Cookie: uid=\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
      end

      it "should create unique cookies" do
        cookie1 = test_class.create_uid_cookie
        cookie2 = test_class.create_uid_cookie
        expect(cookie1).not_to eq(cookie2)
      end

      it "should be able to find the cookie in a request" do
        require "securerandom"
        request_header = <<-EOS
    GET /spec.html HTTP/1.1
    Host: www.example.org
    Cookie: #{SecureRandom.uuid}
    EOS
      expect(test_class.find_uid_cookie(request_header)).to match(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
      end

    end


end
