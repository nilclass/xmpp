
class XMPP::JID
  attr :local_name
  attr :hostname
  attr :resource

  def initialize(jid)
    _, @local_name, @hostname, @resource = *jid.match(/^([^@]+)@([^\/]+)(?:\/(.+))?$/)
  end

  def to_s
    "#{local_name}@#{hostname}#{resource ? ('/' + resource) : ''}"
  end

  def resolve_host
    resolver = Resolv::DNS.new
    resource = resolver.getresource(
                        "_xmpp-client._tcp.#{hostname}",
                        Resolv::DNS::Resource::IN::ANY)
    target = resource.target
    return target.to_s
  rescue Resolv::ResolvError
    return hostname
  end
end
