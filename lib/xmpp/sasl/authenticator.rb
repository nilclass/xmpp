
class XMPP::SASL::Authenticator
  attr :client

  def initialize(client)
    @client = client
  end
end
