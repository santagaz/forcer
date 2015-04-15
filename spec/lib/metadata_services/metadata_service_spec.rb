require "spec_helper"
require_relative "../../../lib/metadata_services/metadata_service"
require "savon/mock/spec_helper"

describe Metadata::MetadataService do

  include Savon::SpecHelper

  # let(:args) {
  #   {
  #     host: "https://fake.salesforce.com",
  #     username: "test_username",
  #     password: "test_password",
  #     security_token: "test_token"
  #   }
  # }

  # prepare savon mock for soap calls
  before(:all) do
    savon.mock!
    args = {
        host: "https://fake.salesforce.com",
        username: "test_username",
        password: "test_password",
        security_token: "test_token"
    }
    fixture_login_response = File.read("spec/fixtures/login_response.xml")
    message = {
        username: "test_username",
        password: "test_passwordtest_token"
    }
    savon.expects(:login).with(message: message).returns(fixture_login_response)
    @service = Metadata::MetadataService.new(
      File.expand_path("../../../fixtures/TestProject", __FILE__),
      args)
  end

  after(:all) { savon.unmock! }

  # runs after savon is mocked
  # let(:service) {  }

  describe "#initialize" do
    it "authenticates" do
      expect(@service.current_session_id).to eq("test_session_id")
    end

    it "creates metadata client" do
      expect(@service.metadata_client.operations).to
    end
  end

end