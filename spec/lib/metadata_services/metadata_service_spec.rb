require "spec_helper"
require_relative "../../../lib/metadata_services/metadata_service"
require "savon/mock/spec_helper"
require "matchers/include_xml_tag"
require "mocks/mock_response"

describe Metadata::MetadataService do

  include Savon::SpecHelper

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

  context "services" do
    before(:each) do
      @metadata = double()
      @service.metadata_client = @metadata
    end

    describe "#deploy" do
      it "receives xml template" do
        allow(@metadata).to receive(:call).with(:deploy, any_args) do |name, message|
          expect(message[:xml]).to include_xml_tag("<met:sessionId>test_session_id</met:sessionId>")
          Forcer::MockResponse.new(:deploy)
        end

        @service.deploy
      end

      it "queues deployment" do
        allow(@metadata).to receive(:call).with(:deploy, any_args) do
          Forcer::MockResponse.new(:deploy)
        end
        @service.deploy
      end
    end

    describe "#list" do
      it "prepares xml with types to list" do
        allow(@metadata).to receive(:call).with(:list_metadata, any_args) do |name, message|
          expect(message[:xml]).to include_xml_tag("<met:type>CustomObject</met:type>")
          Forcer::MockResponse.new(:list_metadata)
        end
        @service.list
      end

      # it "lists metadata objects" do
      # end
    end
  end # services context
end # MetadataService test