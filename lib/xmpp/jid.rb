
def XMPP::JID(jid)
  return jid if jid.kind_of?(XMPP::JID)
  XMPP::JID.new(jid)
end

class XMPP::JID
  DEFAULT_PORT = 5222

  attr :local_part
  attr :hostname
  attr :resource

  def initialize(jid)
    _, @local_part, @hostname, @resource = *jid.match(/^([^@]+)@([^\/]+)(?:\/(.+))?$/)
  end

  def ==(other)
    other.to_s == to_s
  end

  def =~(other)
    XMPP::JID(other).bare == bare
  end

  def bare
    "#{local_part}@#{hostname}"
  end

  def to_s
    "#{bare}#{resource ? ('/' + resource) : ''}"
  end

  def resolve_host
    resolver = Resolv::DNS.new
    resource = resolver.getresource(
                        "_xmpp-client._tcp.#{hostname}",
                        Resolv::DNS::Resource::IN::ANY)
    target = resource.target
    return [target.to_s, resource.port]
  rescue Resolv::ResolvError
    return [hostname, DEFAULT_PORT]
  end
end
