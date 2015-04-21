require "rspec"
require_relative "../../../lib/utilities/action_options_service"

describe 'Forcer::ActionOptionsService' do

  before(:all) do
    @init_directory = Dir.pwd
    Dir.chdir(File.expand_path("../../../fixtures/TestProject", __FILE__)) # search configuration.yml in current directory
  end

  after(:all) do
    Dir.chdir(@init_directory)
  end

  context "org information found" do
    before(:all) do
      @options = {dest: "fake_sandbox"}
      @options = Forcer::ActionOptionsService.load_config_file(@options)
    end

    describe "#load_config_file" do

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
  end # context "org information found"

  context "org information not found" do
    describe "#initialize" do
      before(:all) do
        @options = {dest: "not_exising_org"}
        @options = Forcer::ActionOptionsService.load_config_file(@options)
      end

      it "skips destination url" do
        expect(@options[:dest_url]).to be_nil
      end

      it "skips security token" do
        expect(@options[:security_token]).to be_nil
      end

      it "skips username" do
        expect(@options[:username]).to be_nil
      end
    end
  end # context "org not found in file"

  context "yaml not found" do
    before(:all) do
      @config_name = File.join(Dir.pwd, "configuration.yml")
      File.rename(@config_name, @config_name + "dummy_string")
      @options = {dest: "fake_sandbox"}
      @options = Forcer::ActionOptionsService.load_config_file(@options)
    end

    it "skips destination url" do
      expect(@options[:dest_url]).to be_nil
    end

    it "skips security token" do
      expect(@options[:security_token]).to be_nil
    end

    it "skips username" do
      expect(@options[:username]).to be_nil
    end

    after(:all) do
      File.rename(@config_name + "dummy_string", @config_name)
    end
  end
end # unit test