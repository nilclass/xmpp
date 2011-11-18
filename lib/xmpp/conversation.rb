require 'digest/sha1'

class XMPP::Conversation
  attr :jid
  attr :id
  attr :client
  attr :otr

  def initialize(jid, client)
    @jid = XMPP::JID(jid)
    @client = client
    @id = generate_id
    @otr = true
  end

  def sent_message(message)
    # stub
  end

  def received_message(message)
    # stub
  end

  def filter_outgoing(body)
    return unless body
    if @otr
      client.otr.sending(@jid.to_s, body)
    else
      body
    end
  end

  def filter_incoming(body)
    return unless body
    if @otr
      client.otr.receiving(@jid.to_s, body)
    else
      body
    end
  end

  private

  def generate_id
    Digest::SHA1.hexdigest(@jid.to_s + 10.times.map { [('A'..'Z').to_a + ('a'..'z').to_a][rand(52)] }.join)
  end
end
