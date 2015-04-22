require 'rspec'
require_relative "../../../lib/metadata_services/sfdc_directory_service"
require "zip"

describe 'Metadata::SfdcDirectoryService' do

  before(:all) do
    @test_project_path = File.expand_path("../../../fixtures/TestProject", __FILE__)
    @test_exclude_file_path = File.expand_path("../../../fixtures/exclude_components.yml", __FILE__)
    @directory_service = Metadata::SfdcDirectoryService.new(@test_project_path, @test_exclude_file_path)
    @path_package_xml = File.join(@test_project_path, "/project/src/package.xml")
    @temp_zip_filename = @directory_service.write
    @zip_file = Zip::File.open(@temp_zip_filename)
  end

  after(:all) do
    FileUtils.rm_rf @temp_zip_filename if File.exists?(@temp_zip_filename)
    @zip_file.close
  end

  describe "#write" do
    it "produces zip file" do
      expect(File.exists?(@temp_zip_filename)).to be_truthy
      expect(@temp_zip_filename).to include(".zip")
    end

    it "checks if package.xml exists" do
      expect(File.exists?(@path_package_xml)).to eq(true)
    end

    it "excludes files using exclude.yml" do
      expect(@zip_file.find_entry("classes/FileToExclude.cls")).to be_nil
      expect(@zip_file.find_entry("classes/FileToExclude.cls-meta.xml")).to be_nil
    end

  end

  describe "zip file" do
    it "contains file from source" do
      expect(@zip_file.find_entry("classes/DummyClass.cls")).to_not be_nil
      expect(@zip_file.find_entry("package.xml")).to_not be_nil
      expect(@zip_file.find_entry("NOT_EXISTING_FILE")).to be_nil
    end
  end
end