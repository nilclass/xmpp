class XMPP::Message < XMLStreaming::Stanza
  register(:message, self)

  def body
    children.select { |child|
      child.name == 'body'
    }.first.text
  end
end
