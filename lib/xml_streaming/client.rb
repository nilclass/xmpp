
class XMLStreaming::Client < EventMachine::Connection
  attr :stream
  attr :parser

  def post_init
    @stream = XMLStreaming::Stream.new(self)
    @parser = Nokogiri::XML::SAX::PushParser.new(@stream)
  rescue => exc
    log_exception(exc)
  end

  def receive_data(data)
    $stderr.puts "RECEIVED: #{data}"
    @parser << data
  rescue => exc
    log_exception(exc)
  end

  def send_data(data)
    $stderr.puts "SENDING: #{data}"
    super(data)
  end

  def send_stanza(stanza)
    send_data(stanza.to_xml)
  end

  def receive_stanza(stanza)
    # stub, to be overwritten by subclasses
  end

  def root_opened
    # stub, to be overwritten by subclasses
  end

  def log(type, message)
    $stdout.puts("#{type.to_s.upcase}: #{message}")
  end

  def log_exception(exc)
    log(:exception, exc.message)
    log(:exception, exc.class.to_s)
    exc.backtrace.each do |line|
      log(:exception, line)
    end
  end
end
