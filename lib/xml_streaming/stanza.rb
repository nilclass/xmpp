
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

  def from ; attributes[:from] ; end
  def to   ; attributes[:to]   ; end
  def type ; attributes[:type] ; end
  def id   ; attributes[:id]   ; end
end
