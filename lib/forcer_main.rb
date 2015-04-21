require "forcer/version"
require "thor"
require_relative "utilities/action_options_service"

module Forcer
  class ForcerMain < Thor
    class_option :dest, required: true
    class_option :config

    option :source
    desc "deploy --dest destination_org_name", "Deploys project on local machine to destination org. Destination org" +
       " name should be specified in configuration.yml. Forcer asks for any information missing from configuration.yml"
    def deploy
      ConsoleOptionsService.parse(options)
    end
  end
end
