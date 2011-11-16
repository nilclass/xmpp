
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
    msg = XMLStreaming::Element.new('message', { :type => 'chat', :to => options[:to] }, nil, nil, [])
    body = XMLStreaming::Element.new('body', {}, nil, nil, [])
    body.add_text(options[:body])
    msg.add_child(body)
    @client.send_stanza(msg)
    if conversation = @conversations[XMPP::JID.new(options[:to]).bare]
      conversation.sent_message(conversation)
      client.ui.trigger(:chat_message, :from => client.jid.to_s, :body => options[:body], :id => conversation.id)
    end
  end
end
