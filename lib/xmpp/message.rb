class XMPP::Message < XMLStreaming::Stanza
  register(:message, self)
end
