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
      expect(test_class.get_http_resource(simple_request_header)).to eq("/index.html")
    end

    it "should get an entire resource that is several levels deep" do
      expect(test_class.get_http_resource(complex_request_header)).to eq("/index/users/3.html")
    end

  end

    context "extract query parameters" do

      let(:query_parameter_header){"GET /welcome?first=Phil&last=Sugg HTTP/1.1"}

      it 'should correctly extract the first and last name at the welcome screen' do
        query_parameter_resource = test_class.get_http_resource(query_parameter_header)
        expect(test_class.parse_name_query_parameters(query_parameter_resource)).to eq({"first"=>["Phil"], "last"=>["Sugg"]})
      end


    end



end
