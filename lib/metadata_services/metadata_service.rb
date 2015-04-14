require "savon"
require File.dirname(__FILE__) + "/project_directory_service.rb"

module Metadata
  class MetadataService

    API_VERSION = 33.0 # todo move to constants file

    def initialize(target_dir_name = File.expand_path("./", __FILE__))
      # todo check if target_dir_name exists
      @target_dir_name = target_dir_name
      @metadata_client = get_client
    end

    def list
      # todo reference file with all types
      queries = "<met:type>CustomObject</met:type><met:folder>CustomObject</met:folder>"

      list_metadata_request = File.read(File.dirname(__FILE__) + "/list_metadata_request.xml")
      xml_param = list_metadata_request % [@current_session_id, queries, API_VERSION]
      @metadata_client.call(:list_metadata, :xml => xml_param)
    end

    def deploy
      dir_zip_service = ProjectDirectoryService.new(@target_dir_name)
      zip_name = dir_zip_service.write
      blob_zip = Base64.encode64(File.open(zip_name, "rb").read)

      # todo read options from console arguments
      options = {
        singlePackage: true,
        rollbackOnError: true,
        checkOnly: true,
        allowMissingFiles: false,
        runAllTests: false,
        ignoreWarnings: false
      }

      # prepare xml for deployment
      deploy_options_snippet = ""
      options.each do |k, v|
        key = k.to_s
        val = v.to_s
        # todo take care of array options
        deploy_options_snippet += "<met:#{key}>#{val}</met:#{key}>"
      end

      debug_options_snippet = "" #by default no debug options

      deploy_request_xml = File.read(File.dirname(__FILE__) + "/deploy_request.xml");
      xml_param = deploy_request_xml % [debug_options_snippet, @current_session_id, blob_zip, deploy_options_snippet]
      response = @metadata_client.call(:deploy, :xml => xml_param)
      p "DEPLOYMENT FAILED. CHECK DEPLOYMENT STATUS LOG IN SALESFORCE ORG." unless response.body[:deploy_response][:result] == "Queued"
    ensure
      FileUtils.rm_f zip_name

    end

    private
    def login
      # todo read endpoint_url from yaml
      endpoint_url = "https://test.salesforce.com"
      options = {
        endpoint: "#{endpoint_url}/services/Soap/c/#{API_VERSION}",
        wsdl: File.expand_path("../enterprise.wsdl", __FILE__),
        :headers => {
          "Authentication" => "secret"
        }
      }
      enterprise_client = Savon.client(options)

      # todo read credentials from yaml
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
      options = {
        wsdl: File.expand_path("../metadata.wsdl", __FILE__),
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

# metadata_service = Metadata::MetadataService.new(File.expand_path("../../../tmp/TestProject", __FILE__))
# p metadata_service.list
# p metadata_service.deploy.body[:deploy_response][:result][:state]
