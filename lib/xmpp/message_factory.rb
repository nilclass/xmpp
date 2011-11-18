
class XMPP::MessageFactory
  attr :client

  def initialize(client)
    @client = client
    @conversations = {}

    client.callbacks.add(:message) do |stanza|
      stanza = XMPP::Message.cast(stanza)
      if stanza.attr(:type) ==  'chat'
        if conversation = @conversations[stanza.from_jid.bare]
          conversation.received_message(stanza.body)
          stanza.body = conversation.filter_incoming(stanza.body)
        end
        client.ui.trigger(:chat_message,
          :from => stanza.from,
          :body => stanza.body,
          :id => conversation ? conversation.id : nil
        )
      end
    end
  end

  def register_conversation(conversation)
    @conversations[conversation.jid.bare] = conversation
  end

  def chat(options)
    conversation = @conversations[XMPP::JID.new(options[:to]).bare]
    msg = XMLStreaming::Element.new('message', { :type => 'chat', :to => options[:to] }, nil, nil, [])
    body = XMLStreaming::Element.new('body', {}, nil, nil, [])
    body_text = options[:body]
    body_text = conversation.filter_outgoing(body_text) if conversation
    body.add_text(body_text)
    msg.add_child(body)
    @client.send_stanza(msg)
    if conversation
      conversation.sent_message(conversation)
      client.ui.trigger(:chat_message, :from => client.jid.to_s, :body => options[:body], :id => conversation.id)
    end
  end
end
