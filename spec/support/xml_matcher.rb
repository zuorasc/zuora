require 'libxml'

RSpec::Matchers.define :have_xml do |xpath|
  @value = nil
  chain :with_value do |value|
    @value = value
  end

  match do |body|
    parser = LibXML::XML::Parser.string body
    doc = parser.parse
    nodes = doc.find(xpath)
    if @value
      opper, match = @value.is_a?(Regexp) ? ['=~', @value] : ['==', @value.to_s]
      nodes.map do |node|
        node.content.to_s.send(opper, match)
      end.any?
    else
      !nodes.empty?
    end
  end

  failure_message_for_should do |body|
    if @value
      "expected to find xml tag #{xpath} with value '#{@value}' in:\n#{body}"
    else
      "expected to find xml tag #{xpath} in:\n#{body}"
    end
  end

  failure_message_for_should_not do |response|
    if @value
      "expected not to find xml tag #{xpath} with value '#{@value}' in:\n#{body}"
    else
      "expected not to find xml tag #{xpath} in:\n#{body}"
    end
  end

  description do
    "have xml tag #{xpath}"
  end
end
