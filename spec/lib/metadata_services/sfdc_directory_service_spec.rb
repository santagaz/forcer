require 'rspec'
require_relative "../../../lib/metadata_services/sfdc_directory_service"

describe 'Metadata::SfdcDirectoryService' do

  before(:all) do
    @path = File.expand_path("../../../fixtures/TestProject", __FILE__)
    @directory_service = Metadata::SfdcDirectoryService.new(@path)
    @path_package_xml = File.join(@path, "package.xml")
  end

  it "produce zip file" do
    expect(@directory_service.write).to include(".zip")
  end

  it "checks if package.xml exists" do
    expect(File.exists?(@path_package_xml)).to eq(true)
  end
end