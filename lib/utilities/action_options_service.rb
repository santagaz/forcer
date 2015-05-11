require "yaml"

module Forcer
  class ActionOptionsService

    # attempts to load configuration files from directory 'forcer_config'
    # directory can include 'configuration.yml', 'exclude_components.yml', 'exclude_xml_nodes.yml'
    # if directory not found tries to load only configuration.yml from local directory
    def self.load_config(old_options = {})
      options = {}
      old_options.each do |k, v|
        options.store(k.to_sym, v)
      end

      if options[:configs].nil? || !(Dir.exists?(File.expand_path(options[:configs], __FILE__)))
        p "config folder not specified or not found"
        options[:configs] = Dir.pwd + "/forcer_config"
        p "config folder in CURRENT DIRECTORY ? => #{Dir.exists?(options[:configs])}"
      else
        p "specified config folder FOUND"
        options[:configs] = File.expand_path(options[:configs], __FILE__)
      end

      load_login_info(options)

      add_exclude_paths(options)

      return options
    end

    private

    class << self

      # attempts to read salesforce org information from forcer_config/configuration.yml
      # if forcer_config/configuration.yml not found, then try configuration.yml in current directory
      def load_login_info(options = {})

        if !(options[:configs].nil?) && File.exists?(File.join(options[:configs], "/configuration.yml"))
          p "CONFIGURATION.YML with org details FOUND in CONFIG FOLDER"
          config_file_path = File.join(options[:configs], "/configuration.yml")
          options[:login_info_path] = config_file_path
        else
          p "loading CONFIGURATION.YML from CURRENT DIRECTORY"
          config_file_path = File.join(Dir.pwd, "/configuration.yml")
        end

        return options unless File.exists?(config_file_path)

        dest = options[:dest]
        configuration = YAML.load_file(config_file_path).to_hash

        return options if configuration[dest].nil?

        configuration[dest].each do |key, value|
          options.store(key.to_sym, value.to_s)  unless value.to_s.empty?
        end
        options[:host] = "https://#{options[:host]}" unless options[:host].include?("http")
      end # load_login_info


      # add absolute paths to exclude_... files from focer_config directory
      def add_exclude_paths(options = {})

        if !(options[:configs].nil?) && File.exists?(File.join(options[:configs], "/exclude_components.yml"))
          options[:exclude_components] = File.join(options[:configs], "/exclude_components.yml")
        end

        if !(options[:configs].nil?) && File.exists?(File.join(options[:configs], "/exclude_xml_nodes.yml"))
          options[:exclude_xml] = File.join(options[:configs], "/exclude_xml_nodes.yml")
        end
      end

    end # class << self

  end # class ActionOptionsService
end