
class UI::Controller::Conversation < UI::Controller::Base
  def initialize(*args)
    super(*args)
    @conversations = {}
  end

  def start(params, *args)
    jid = XMPP::JID(params['jid'])
    unless conversation = conversation_for(jid)
      conversation = @conversations[jid.bare] = XMPP::Conversation.new(jid, connection.client)
      connection.client.message.register_conversation(conversation)
    end
    connection.trigger('start_conversation', :jid => jid, :id => conversation.id)
  end

  def say(params, *args)
    to = params['to']
    body = params['body']
    connection.client.message.chat(:to => to, :body => body)
  end

  def conversation_for(jid)
    @conversations[jid.to_s]
  end
end
