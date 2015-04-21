require "rspec"
require_relative "../../../lib/utilities/action_options_service"

describe 'Forcer::ActionOptionsService' do

  before(:all) do
    @init_directory = Dir.pwd
    Dir.chdir("fixtures/TestProject")
    @service = Forcer::ActionOptionsService.new
  end

  after(:all) do
    Dir.chdir(@init_directory)
  end

  # username: "test_username",
  # password: "test_password",
  # security_token: "test_token",
  describe "#prepare_options" do

    before(:each) do
      @service.prepare_options(@options)
    end

    it "loads options from config.yml" do
      expect(@options[:username]).to eq("test_username")
      expect(@options[:password]).to eq("test_password")
      expect(@options[:security_token]).to eq("test_token")
    end
  end
end