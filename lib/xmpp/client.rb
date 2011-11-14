class XMPP::Client < XMLStreaming::Client
  attr :jid
  attr :state
  attr :callbacks
  attr :sasl
  attr :ui

  def self.connect(ui, jid)
    jid = XMPP::JID.new(jid) unless jid.is_a?(XMPP::JID)
    xmpp_host, port = jid.resolve_host
    EM.connect(xmpp_host, port, self, ui, jid)
  end

  def initialize(ui, jid=nil)
    @ui = ui
    @jid = jid.is_a?(XMPP::JID) ? jid : XMPP::JID.new(jid)
    @callbacks = XMPP::Client::Callbacks.new
    @sasl = XMPP::SASL.new(self)
    jump(:init)
    super()
  end

  def jump(state)
    old_state = @state
    @state = state
    log(:state, "#{old_state} -> #{state}")
    send("on_#{state}")
  rescue => exc
    log_exception(exc)
  end

  def unbind
    jump(:closed)
  end

  def on_closed
  end

  def receive_stanza(stanza)
    log(:receive, stanza.to_s)
    callbacks.call(stanza.name.to_sym, stanza)
  end

  def on_init
    stream = XMLStreaming::Element.new(
      'stream', {
        :to => jid.hostname,
        :version => '1.0'
      },
      'stream',
      'jabber:client',
      [['stream', 'http://etherx.jabber.org/streams']]
    )
    send_data(stream.to_xml(:start))
  end

  def on_open
    callbacks.once(:features) { |features|
      upgrade_stream(features)
    }
  end

  def root_opened
    jump(:open)
  end

  def upgrade_stream(features)
    if features.starttls?
      log(:info, "Starting TLS")
      negotiate_tls
    elsif features.mechanisms?
      params = features.mechanisms.inject({}) do |params, mech|
        if authenticator = sasl.authenticator(mech)
          params[mech] = authenticator.params
        end
        next(params)
      end
      if params.size > 0
        ui.trigger(:auth_params, :params => params)
      else
        ui.trigger(:auth_failure, :message => "No usable Authenticator. Server supports mechanisms: #{features.mechanisms.join(', ')}")
      end
    end
  end

  def ssl_handshake_completed
    log(:info, "SSL handshake completed")
    post_init
    jump(:init)
  end

  def negotiate_tls
    callbacks.once(:proceed) do |_|
      start_tls
    end
    send_stanza(XMLStreaming::Element.new('starttls', {}, nil, 'urn:ietf:params:xml:ns:xmpp-tls', []))
  end
end
