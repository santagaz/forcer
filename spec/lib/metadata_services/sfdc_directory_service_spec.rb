require 'rspec'
require_relative "../../../lib/metadata_services/sfdc_directory_service"

describe 'Metadata::SfdcDirectoryService' do

  before(:all) do
    @directory_service = Metadata::SfdcDirectoryService.new(File.expand_path("../../../fixtures/TestProject", __FILE__))
  end

  it "produce zip file" do
    expect(@directory_service.write).to include(".zip")
  end

  it "checks if package.xml exists" do
    expect(@directory_service.write).to output("package.xml FOUND")
  end
end