require 'nokogiri'

RSpec::Matchers.define :include_xml_tag do |tag|
  match do |body|
    doc = Nokogiri::XML::Document.parse(body)

    # prepare fixture tag for matching
    tag_parsed = Nokogiri::XML::Document.parse(tag)
    target_node = tag_parsed.xpath("/*").first
    target_node_name = target_node.name
    value = target_node.content

    # fixture tag is <met:sessionId>, need to register namespace "met"
    nodes = doc.xpath("//#{target_node_name}", "met" => "http://soap.sforce.com/2006/04/metadata")
    expect(nodes).not_to be_empty
    found = false
    if value
      nodes.each do |node|
        found = true if node.content.to_s == value.to_s
      end
    end

    return found
  end

  # todo fix messages for custom tag
  # failure_message do |actual|
  #   "expected to find xml tag #{tag}"
  # end
  #
  # match do |actual|
  #   "not expected to find xml tag #{tag}"
  # end

  description do
    "have xml tag #{tag}"
  end
end