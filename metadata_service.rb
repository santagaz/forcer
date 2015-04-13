require "savon"
require "./project_directory_service.rb"

module Metadata
  API_VERSION = 33.0

  class MetadataService

    def initialize()
      @metadata_client = get_client
    end

    def list
      queries = "<met:type>CustomObject</met:type><met:folder>CustomObject</met:folder>"
      list_metadata_request = File.read("./list_metadata_request.xml");
      xml_param = list_metadata_request % [@current_session_id, queries, API_VERSION]
      @metadata_client.call(:list_metadata, :xml => xml_param)
    end

    def deploy
      target_dir_name = "/Users/gt/Desktop/TestProject"
      dir_zip_service = ProjectDirectoryService.new(target_dir_name)
      zip_name = dir_zip_service.write
      p "zip_name = #{zip_name}"
      zip_file = File.open(zip_name, "r");

      # TODO read options from console arguments
      options = {
        singlePackage: true,
        rollbackOnError: true,
        checkOnly: false,
        allowMissingFiles: false,
        runAllTests: false,
        ignoreWarnings: false
      }

      # prepare xml for deployment
      deploy_options_snippet = ""
      options.each do |k, v|
        key = k.to_s
        val = v.to_s
        deploy_options_snippet += "<met:#{key}>#{val}</met:#{key}>"
      end

      debug_options_snippet = "" #by default no debug options

      deploy_request_xml = File.read("./deploy_request.xml");
      xml_param = deploy_request_xml % [debug_options_snippet, @current_session_id, zip_file, deploy_options_snippet]
      @metadata_client.call(:deploy, :xml => xml_param)
      
    ensure
      FileUtils.rm_f zip_name
    end

    private
    def login
      endpoint_url = "https://test.salesforce.com"
      options = {
        endpoint: "#{endpoint_url}/services/Soap/c/#{API_VERSION}",
        wsdl: "./enterprise.wsdl", 
        :headers => {
          "Authentication" => "secret"
        }
      }
      enterprise_client = Savon.client(options)
      # p enterprise.operations

      message = {
        username: "gaziz@eventbrite.com.comitydev",
        password: "?kMMTR[d}X7`Fd}>@T.fpX1t6k2We39Qtq42NKbnLWSQ"
      }

      # === login
      response = enterprise_client.call(:login, message: message)
      @current_session_id = response.body[:login_response][:result][:session_id]
      @metadata_server_url = response.body[:login_response][:result][:metadata_server_url]
    end

    def get_client
      login
      # p "session id = #{current_session_id}"
      options = {
        wsdl: "./metadata.wsdl",
        endpoint: @metadata_server_url,
        soap_header: {
          "tns:SessionHeader" => {
            "tns:sessionId" => @current_session_id
          }
        },
        read_timeout: 60 * 10,
        open_timeout: 60 * 10
      }
      Savon.client(options)
    end

  end # class MetadataService
end # module Metadata

# test area

metadata_service = Metadata::MetadataService.new()
# p metadata_service.list
metadata_service.deploy
