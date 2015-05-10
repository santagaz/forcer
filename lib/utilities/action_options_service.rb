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

      if options[:config_dir].nil? || !(Dir.exists?(File.expand_path(options[:config_dir], __FILE__)))
        p "config folder not specified or not found"
        options[:config_dir] = Dir.pwd + "/forcer_config"
        p "config folder in CURRENT DIRECTORY ? => #{Dir.exists?(options[:config_dir])}"
      else
        p "specified config folder FOUND"
        options[:config_dir] = File.expand_path(options[:config_dir], __FILE__)
      end

      load_login_info(options)

      # load_exclude_info(options)

      return options
    end

    class << self

      # attempts to read salesforce org information from forcer_config/configuration.yml
      # if forcer_config/configuration.yml not found, then try configuration.yml in current directory
      def load_login_info(options = {})

        if !(options[:config_dir].nil?) && File.exists?(File.join(options[:config_dir], "/configuration.yml"))
          p "CONFIGURATION.YML with org details FOUND in CONFIG FOLDER"
          config_file_path = File.join(options[:config_dir], "/configuration.yml")
          options[:login_info_path] = config_file_path
        else
          p "attempt to load CONFIGURATION.YML from CURRENT DIRECTORY"
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

    end # class << self

  end # class ActionOptionsService
end