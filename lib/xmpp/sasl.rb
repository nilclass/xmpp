
class XMPP::SASL
  NS = 'urn:ietf:params:xml:ns:xmpp-sasl'

  class << self
    def register(mechanism, klass)
      authenticators[mechanism] = klass
    end

    def authenticators
      @authenticators ||= {}
    end
  end

  attr :client

  def initialize(client)
    @client = client
  end

  def authenticator(mechanism)
    if klass = self.class.authenticators[mechanism]
      klass.new(client)
    end
  end
end
