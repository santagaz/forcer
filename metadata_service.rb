require 'savon'

module Metadata
  API_VERSION = 33.0

  class MetadataService
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

    def list_metadata
      client = get_client
      queries = "<met:type>CustomObject</met:type><met:folder>CustomObject</met:folder>"
      list_metadata_request = File.read("./list_metadata_request.xml");
      xml_param = list_metadata_request % [@current_session_id, queries]
      client.call(:list_metadata, :xml => xml_param)
    end

  end # class MetadataService
end # module Metadata

metadata_client = Metadata::MetadataService.new()
p metadata_client.list_metadata
