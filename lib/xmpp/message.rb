class XMPP::Message < XMLStreaming::Stanza
  register(:message, self)

  def body
    body_element.text if body_element
  end

  def body=(text)
    if body_element
      body_element.text = text
    end
  end

  private

  def body_element
    children.select { |child|
      child.name == 'body'
    }.first
  end
end
