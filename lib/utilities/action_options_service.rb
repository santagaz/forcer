require "yaml"

module Forcer
  class ActionOptionsService

    def initialize(options = {})
      @options = options
      load_config_file
    end

    def load_config_file
      config_file_path = File.join(Dir.pwd, "/configuration.yml")
      return unless File.exists?(config_file_path)

      dest = @options[:dest]
      configuration = YAML.load_file(config_file_path).to_hash

      return if configuration[dest].nil?

      configuration[dest].each do |key, value|
        @options.store(key.to_sym, value.to_s)
      end
      @options[:dest_url] = "https://#{@options[:dest_url]}" unless @options[:dest_url].include?("http")
    end
  end
end