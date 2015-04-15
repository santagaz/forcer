require 'nokogiri'
RSpec::Matchers.define :include_xml_tag do |xpath, value|
  match do |body|
    doc = Nokogiri::XML::Document.parse(body)
    nodes = doc.xpath(xpath)
    expect(nodes).to not_to be_empty
    if value
      nodes.each do |node|
        expect(node.content).to eq(value)
      end
    end
    true
  end

  failure_message_for_should do |body|
    "expected to find xml tag #{xpath} in:\n#{body}"
  end

  failure_message_for_should_not do |response|
    "not expected to find xml tag #{xpath} in:\n#{body}"
  end

  description do
    "have xml tag #{xpath} with value #{value}"
  end
end