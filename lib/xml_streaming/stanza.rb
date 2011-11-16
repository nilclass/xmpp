
class XMLStreaming::Stanza < XMLStreaming::Element
  class << self
    def new(*args)
      if self == XMLStreaming::Stanza
        if klass = registered_subclasses[args.first.to_sym]
          return klass.new(*args)
        end
      end
      stanza = allocate
      stanza.send(:initialize, *args)
      return stanza
    end

    def registered_subclasses
      @subclasses ||= {}
    end

    def register(key, klass)
      if self == XMLStreaming::Stanza
        registered_subclasses[key.to_sym] = klass
      else
        XMLStreaming::Stanza.register(key, klass)
      end
    end
  end

  def from ; attr(:from) ; end
  def to   ; attr(:to)   ; end
  def type ; attr(:type) ; end
  def id   ; attr(:id)   ; end

  def from_jid ; XMPP::JID(attr(:from)) ; end
  def to_jid ; XMPP::JID(attr(:from)) ; end
end
