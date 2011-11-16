
class XMPP::IQFactory
  CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  attr :client

  def initialize(client)
    @client = client
    @callbacks = {}
    client.callbacks.add(:iq) do |stanza|
      if callback = @callbacks.delete(stanza.attr(:id))
        callback.call(*stanza.children)
      end
    end
  end

  def query(namespace, &cb)
    q = XMLStreaming::Element.new('query', {}, nil, namespace, [])
    get(q, &cb)
  end

  def get(child=nil, options={}, &block)
    iq = build_iq(options.merge(:type => 'get'))
    iq.add_child(child)
    @callbacks[iq.id] = block
    client.send_stanza(iq)
  end

  def set(child=nil, options={}, &block)
    iq = build_iq(options.merge(:type => 'set'))
    iq.add_child(child)
    @callbacks[iq.id] = block
    client.send_stanza(iq)
  end

  private

  def build_iq(options)
    XMLStreaming::Stanza.new('iq', options.merge(
      :from => client.jid.to_s,
      :id => generate_id
    ), nil, nil, [])
  end

  def generate_id
    12.times.map { CHARS[ rand(CHARS.size) ] }.join
  end
end
