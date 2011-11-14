
class XMPP::SASL::Authenticator::Plain < XMPP::SASL::Authenticator

  XMPP::SASL.register('PLAIN', self)

  def params
    { :password => 'Password' }
  end

  def run(params)
    jid = params[:jid]
    password = params[:password]
    text = Base64.encode64("\0#{jid.local_part}\0#{password}")
    stanza = XMLStreaming::Element.new('auth', {
                                         :mechanism => 'PLAIN'
                                       }, nil,
                                       XMPP::SASL::NS, [])
    stanza.add_text(text)
    cbs = []
    cbs << client.callbacks.add(:success) do |stanza|
      client.callbacks.remove(*cbs)
      client.jump(:auth)
    end
    cbs << client.callbacks.add(:failure) do |stanza|
      client.callbacks.remove(*cbs)
      client.ui.trigger(:auth_failure, :message => "Authentication failed! Reason given by server: #{stanza.children.first.name}")
    end
    client.send_stanza(stanza)
  end
end
