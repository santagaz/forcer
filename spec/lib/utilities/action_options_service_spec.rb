require "rspec"
require_relative "../../../lib/utilities/action_options_service"
require "fileutils"

describe 'Forcer::ActionOptionsService' do

  before(:all) do
    @init_directory = Dir.pwd

    # change current directory to project containing somewhere src
    Dir.chdir(File.expand_path("../../../fixtures/TestProject", __FILE__))

    # initially run WITHOUT 'forcer_config'
    # compatibility with older forcer versions
    FileUtils::rm_rf(File.expand_path("../../../fixtures/TestProject/forcer_config", __FILE__))

    # without folder 'forcer_config' in current directory forcer searches only configuration.yml in current directory
    FileUtils::cp(
        File.expand_path("../../../fixtures/forcer_config/configuration.yml", __FILE__),
        File.expand_path("../../../fixtures/TestProject/configuration.yml", __FILE__)
    )
  end

  after(:all) do
    Dir.chdir(@init_directory)
  end

  context "configuration.yml with or without 'forcer_config'" do

    context "org information found" do
      before(:all) do
        @options = {dest: "fake_sandbox"}
        @options = Forcer::ActionOptionsService.load_config(@options)
      end

      describe "#load_config" do

        it "loads destination url from yaml" do
          expect(@options[:host]).to eq("https://test.salesforce.com")
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
        before(:all) do
          @options = {dest: "not_exising_org"}
          @options = Forcer::ActionOptionsService.load_config(@options)
        end

      describe "#load_config" do
        it "skips destination url" do
          expect(@options[:host]).to be_nil
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
          # @config_name = File.join(Dir.pwd, "configuration.yml")
          # File.rename(@config_name, @config_name + "dummy_string")
          FileUtils::rm(File.expand_path("../../../fixtures/TestProject/configuration.yml", __FILE__))
          @options = {dest: "fake_sandbox"}
          @options = Forcer::ActionOptionsService.load_config(@options)
        end

      describe "#load_config" do
        it "skips destination url" do
          expect(@options[:host]).to be_nil
        end

        it "skips security token" do
          expect(@options[:security_token]).to be_nil
        end

        it "skips username" do
          expect(@options[:username]).to be_nil
        end

      end # describe load_config
    end # context 'yaml not found'

  end # context 'with or without forcer_config'

  context "with existing folder 'forcer_config'" do
    before(:all) do
      @forcer_config_path = File.expand_path("../../../fixtures/TestProject/forcer_config", __FILE__)

      FileUtils::cp_r(File.expand_path("../../../fixtures/forcer_config", __FILE__), @forcer_config_path)

      @options = {dest: "fake_sandbox"}
      @options = Forcer::ActionOptionsService.load_config(@options)

      expect(Dir.exists?(@forcer_config_path)).to be_truthy
    end

    it "loads 'configuration.yml' from 'forcer_config'" do
      expect(File.exists?(@forcer_config_path + "/configuration.yml")).to be_truthy
      expect(@options[:login_info_path]).to eq(@forcer_config_path + "/configuration.yml")
    end

    it "adds path to 'exclude_components.yml' from 'forcer_config'" do
      expect(File.exists?(@forcer_config_path + "/exclude_components.yml")).to be_truthy
      expect(@options[:exclude_components]).to eq(@forcer_config_path + "/exclude_components.yml")
    end

    it "adds path to 'exclude_xml_nodes.yml' from 'forcer_config'" do
      expect(File.exists?(@forcer_config_path + "/exclude_xml_nodes.yml")).to be_truthy
      expect(@options[:exclude_xml]).to eq(@forcer_config_path + "/exclude_xml_nodes.yml")
    end

    after(:all) do
      FileUtils::rm_rf(File.expand_path("../../../fixtures/TestProject/forcer_config", __FILE__))
    end
  end # context 'forcer_config' exists
end # unit test