require "spec_helper"
require_relative "../../../lib/metadata_services/metadata_service"
require "savon/mock/spec_helper"
require "matchers/include_xml_tag"
require "mocks/mock_response"

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

    login_info = {
      username: args[:username],
      password: "#{args[:password]}#{args[:security_token]}"
    }
    savon.expects(:login).with(message: login_info).returns(fixture_login_response)

    @service = Metadata::MetadataService.new(
      File.expand_path("../../../fixtures/TestProject", __FILE__),
      args)
  end

  after(:all) { savon.unmock! }

  describe "#initialize" do
    it "authenticates" do
      expect(@service.current_session_id).to eq("test_session_id")
    end

    it "creates metadata client" do
      expect(@service.metadata_client.operations).to include(:deploy, :list_metadata)
    end
  end

  describe "#deploy" do
    before(:each) do
      @metadata = double()
      @service.metadata_client = @metadata
    end

    it "receives xml template" do
      allow(@metadata).to receive(:call).with(:deploy, any_args) do |name, message|
        tag = "<met:sessionId>test_session_id</met:sessionId>"
        expect(message[:xml]).to include_xml_tag(tag)
        Forcer::MockResponse.new
      end

      @service.deploy
    end

    it "queues deployment" do
      allow(@metadata).to receive(:call).with(:deploy, any_args) do
        Forcer::MockResponse.new
      end
      @service.deploy
    end
  end
end