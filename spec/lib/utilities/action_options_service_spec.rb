require "rspec"
require_relative "../../../lib/utilities/action_options_service"

describe 'Forcer::ActionOptionsService' do

  before(:all) do
    @init_directory = Dir.pwd
    Dir.chdir(File.expand_path("../../../fixtures/TestProject", __FILE__)) # search configuration.yml in current directory
    @options = {dest: "fake_sandbox"}
    @service = Forcer::ActionOptionsService.new(@options)
  end

  after(:all) do
    Dir.chdir(@init_directory)
  end

  describe "#initialize" do

    it "loads destination url from yaml" do
      expect(@options[:dest_url]).to eq("https://fake.salesforce.com")
    end

    it "loads username from yaml" do
      expect(@options[:username]).to eq("test_username")
    end

    it "loads security token from yaml" do
      expect(@options[:security_token]).to eq("test_token")
    end
  end
end