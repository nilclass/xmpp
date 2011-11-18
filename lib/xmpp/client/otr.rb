class XMPP::Client::OTR < OTR::UserState
  def sending(*args)
    assure_keys
    super(*args)
  end

  def receiving(*args)
    assure_keys
    super(*args)
  end

  def assure_keys
    generate_privkey unless read_privkey
  end
end
