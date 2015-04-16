require "spec_helper"
require_relative "../../../lib/metadata_services/metadata_service"
require "savon/mock/spec_helper"
require "matchers/include_xml_tag"

describe Metadata::MetadataService do

  include Savon::SpecHelper

  # prepare savon mock for soap calls
  before(:all) do
    savon.mock!
    args = {
      host: "https://fake.salesforce.com",
      username: "test_username",
      password: "test_password",
      security_token: "test_token",
      types: ["CustomObject"]
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

      @mock_deploy_response = double()
      allow(@mock_deploy_response).to receive(:body) do
        {
          :deploy_response => {
            :result => {
              :state=> "Queued",
              :done=> "false"
            }
          }
        }
      end

      @mock_list_response = double()
      allow(@mock_list_response).to receive(:body) do
        {
          :list_metadata_response=>{
            :result=> [{
               :created_by_id=>"test_user_id",
               :created_by_name=>"test_user_firstname test_user_lastname",
               :created_date=>"#<DateTime: 2015-04-15T05:15:21+00:00>",
               :file_name=>"objects/TestSObject__c.object",
               :full_name=>"TestSObject__c",
               :id=>"test_sobject_id",
               :last_modified_by_id=>"test_user_id",
               :last_modified_by_name=>"test_user_firstname test_user_lastname",
               :last_modified_date=>"#<DateTime: 2015-04-15T05:30:01+00:00>",
               :manageable_state=>"unmanaged",
               :type=>"CustomObject"
             }]
          }
        }
      end
    end

    describe "#deploy" do
      it "receives xml template" do
        allow(@metadata).to receive(:call).with(:deploy, any_args) do |name, message|
          expect(message[:xml]).to include_xml_tag("<met:sessionId>test_session_id</met:sessionId>")
          @mock_deploy_response
        end

        @service.deploy
      end

      it "queues deployment" do
        allow(@metadata).to receive(:call).with(:deploy, any_args) do
          @mock_deploy_response
        end
        expect(@service.deploy.body[:deploy_response][:result][:state]).to eq("Queued")
      end
    end

    describe "#list" do
      it "prepares xml with types" do
        allow(@metadata).to receive(:call).with(:list_metadata, any_args) do |name, message|
          expect(message[:xml]).to include_xml_tag("<met:type>CustomObject</met:type>")
          @mock_list_response
        end
        @service.list
      end

      it "lists metadata objects" do
        # @args specified request only for CustomObject
        allow(@metadata).to receive(:call).with(:list_metadata, any_args) { @mock_list_response }
        expect(@service.list.body[:list_metadata_response][:result].first[:full_name].to_s).to eq("TestSObject__c")
      end
    end
  end # services context
end # MetadataService test