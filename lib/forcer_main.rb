require "thor"
require_relative "./forcer/version"
require_relative "./utilities/action_options_service"
require_relative "./metadata_services/metadata_service"

module Forcer
  class ForcerMain < Thor
    class_option :dest
    class_option :config

    option :source
    desc "deploy --dest destination_org_name", "Deploys project on local machine to destination org. Destination org" +
       " name should be specified in configuration.yml. Forcer asks for any information missing from configuration.yml"
    def deploy
      all_options = verify_options(options)
      metadata = Metadata::MetadataService.new(all_options[:source], all_options)
      metadata.deploy
    end


    # these section includes non-console methods to be used internally
    no_commands do
      def verify_options(old_options = {})
        new_options = ActionOptionsService.load_config_file(old_options)
        new_options[:host] ||=  "https://" + ask("Enter org url (test.salesforce.org or login.salesforce.org): ")
        new_options[:username] ||= ask("Enter username: ")
        new_options[:password] ||= ask("Enter password: ", :echo => false)
        new_options[:security_token] ||= ask("Enter security token: ")
        new_options[:source] ||= Dir.pwd
        new_options[:unit_test_running] = false
        return new_options
      end
    end
  end
end
