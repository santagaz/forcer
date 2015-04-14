require 'rspec'
require File.expand_path("../../../../lib/metadata_services/metadata_service", __FILE__)

describe Metadata::MetadataService do
  it "authenticates in sfdc org" do
    client = Metadata::MetadataService.new(File.expand_path("../../../fixtures/TestProject", __FILE__))
  end
end