require 'nokogiri'

RSpec::Matchers.define :include_xml_tag do |tag|
  match do |body|
    doc = Nokogiri::XML::Document.parse(body)
    tag_parsed = Nokogiri::XML::Document.parse(tag)
    target_node = tag_parsed.nodes.first
    target_node_name = target_node.name
    value = target_node.content
    nodes = doc.xpath(target_node_name)
    expect(nodes).to not_to be_empty
    if value
      nodes.each do |node|
        expect(node.content).to eq(value)
      end
    end

    return true
  end

  failure_message_for_should do |body|
    "expected to find xml tag #{tag}"
  end

  failure_message_for_should_not do |response|
    "not expected to find xml tag #{tag}"
  end

  description do
    "have xml tag #{tag}"
  end
end