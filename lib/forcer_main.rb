require "forcer/version"
require "thor"
require_relative "utilities/console_options_service"

module Forcer
  class ForcerMain < Thor
    option :deploy
    option :list_metadata
    option :p
    option :dest

    def self.execute
      ConsoleOptionsService.parse(options)
    end
  end
end
