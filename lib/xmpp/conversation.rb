require 'digest/sha1'

class XMPP::Conversation
  attr :jid
  attr :id

  def initialize(jid)
    @jid = XMPP::JID(jid)
    @id = generate_id
  end

  def sent_message(message)
    # stub
  end

  def received_message(message)
    # stub
  end

  private

  def generate_id
    Digest::SHA1.hexdigest(@jid.to_s + 10.times.map { [('A'..'Z').to_a + ('a'..'z').to_a][rand(52)] }.join)
  end
end
