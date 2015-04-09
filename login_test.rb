require 'savon'

API_VERSION = 33.0

enterprise_headers = {
  "Authentication" => "secret"
}
enterprise_client = Savon.client(wsdl: "/Users/gt/Downloads/enterprise.wsdl.xml", headers: enterprise_headers)
# p enterprise.operations
# username: "gaziz@eventbrite.com.comitydev", password: "?kMMTR[d}X7`Fd}>@T.fpX1t6k2We39Qtq42NKbnLWSQ"

message = {
  username: "gaziz@eventbrite.com.comitydev",
  password: "?kMMTR[d}X7`Fd}>@T.fpX1t6k2We39Qtq42NKbnLWSQ"
}

# === login
response = enterprise_client.call(:login, message: message)
current_session_id = response.body[:login_response][:result][:session_id]
server_url = response.body[:login_response][:result][:server_url]
server_url = server_url.split("\/services")[0]
#current_session_id = current_session_id[0, 15]
# p "session id = #{current_session_id}"
# p "body = #{response.body}"
#p "server url = #{server_url}"

options = {
  wsdl: "/Users/gt/Downloads/metadata.wsdl",
  endpoint: "#{server_url}/services/Soap/c/#{API_VERSION}",
  soap_header: {
    "SessionHeader" => {
      "sessionId" => current_session_id
    }
  }
}
client = Savon.client(options)


# === list metadata
queries = "<met:type>CustomObject</met:type><met:folder>CustomObject</met:folder>"
list_metadata_request = File.read("./list_metadata_request.xml");
xml_param = list_metadata_request % [current_session_id, queries]
response = client.call(:list_metadata, :xml => xml_param)
p response
