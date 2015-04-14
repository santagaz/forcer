require "spec_helper"
require_relative "../../../lib/metadata_services/metadata_service"
require "savon/mock/spec_helper"

describe Metadata::MetadataService do

  include Savon::SpecHelper

  before(:all) do
    savon.mock!
    fixture_login_response = File.read("spec/fixtures/login_response.xml")
    savon.expects(:login).with(anything).returns(fixture_login_response)
  end

  after(:all) { savon.unmock! }

  # runs after savon is mocked
  let(:service) { Metadata::MetadataService.new(
      File.expand_path("../../../fixtures/TestProject", __FILE__)
  ) }

  describe "#initialize" do
    it "authenticates in sfdc org" do
      expect(service.current_session_id).to be("test_session_id")
    end
  end

end