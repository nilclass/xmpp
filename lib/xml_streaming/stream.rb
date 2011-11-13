
class XMLStreaming::Stream < Nokogiri::XML::SAX::Document
  attr :stack
  attr :client

  def initialize(client)
    super()
    @stack = []
    @client = client
  end

  def start_element_namespace(name, attrs=[], prefix=nil, uri=nil, ns=[])
    attrs = attrs.inject({}) { |a, attr|
      a.merge(attr.localname => attr.value)
    }
    if @stack.size == 1
      @stack.push XMLStreaming::Stanza.new(name, attrs, prefix, uri, ns)
    else
      @stack.push XMLStreaming::Element.new(name, attrs, prefix, uri, ns)
    end
    if @stack.size == 1
      # initial element? -> root (usually <stream:stream/>) was opened
      client.root_opened
    end
  end

  def characters(text)
    @stack.last.add_text(text)
  end

  def end_element_namespace(name, prefix=nil, ns=nil)
    element = @stack.pop
    element.finalize!
    if @stack.size > 1
      @stack.last.add_child(element)
    else
      client.receive_stanza(element)
    end
  end
end
