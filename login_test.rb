require 'savon'

partner_headers = {
  "Authentication" => "secret"
}
partner = Savon.client(wsdl: "/Users/gt/Downloads/partner.wsdl", headers: partner_headers)
# p partner.operations
# username: "gaziz@eventbrite.com.comitydev", password: "?kMMTR[d}X7`Fd}>@T.fpX1t6k2We39Qtq42NKbnLWSQ"
message = {
  username: "gaziz@eventbrite.com.comitydev",
  password: "?kMMTR[d}X7`Fd}>@T.fpX1t6k2We39Qtq42NKbnLWSQ"
}

response = partner.call(:login, message: message)
session_id = response.body[:login_response][:result][:session_id]
p "session id = #{session_id}"
