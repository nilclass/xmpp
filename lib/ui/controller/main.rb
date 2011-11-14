
class UI::Controller::Main < UI::Controller::Base
  def connect(jid, *args)
    trigger('connecting', :jid => jid)
    connection.start_xmpp(jid)
  end

  def auth(options, *args)
    authenticator = connection.client.sasl.
      authenticator(options['mechanism'])
    params = options['params'].inject({}) { |p, (k, v)|
      p.merge(k.to_sym => v)
    }
    authenticator.run(params.merge(:jid => connection.client.jid))
  end
end
