require "./lib/otr"
require 'xmpp4r'

JID = "em-test@jabber.ccc.de"
PASS = ""

class OTR::UserState

  def inject_message_cb(to, message)
    puts "\n             injecting message  to #{to}   :   #{message}"
   $client.send(Jabber::Message.new(to, message))
  end

  def create_privkey_cb *args
    puts "\n             generating_private_key"
    generate_privkey
  end
  def display_otr_message_cb accountname, protocol, username, message
    puts "#{protocol}:#{username}   :    #{message}"

  end
  
  def write_fingerprints_cb sucess
    puts "\n              writing fingerprints"
    puts "failed writing  fingerprints" unless sucess
    #write_fingerprints
  end

end

OTR::init

$client = Jabber::Client.new(Jabber::JID.new(JID))
$client.connect
$client.auth(PASS)
$client.send(Jabber::Presence.new.set_type(:available))

@userstate = OTR::UserState.new(JID, "xmpp", "keys.txt", "fingerprints.txt")
@userstate.generate_privkey  unless @userstate.read_privkey
#@userstate.read_fingerprints

$client.add_message_callback do |message|
  $stderr.puts "RECEIVING MESSAGE: #{message}"
  next unless message.body
  begin
    if(decrypted = @userstate.receiving(message.from.to_s, 
                                           message.body))  # this if seems to be improtant for the autetication to work 
      puts 
      puts @userstate.secure?
      puts 
      plain = "you said: #{decrypted}"
      encrypted = @userstate.sending(message.from.to_s, plain)
      msg = Jabber::Message.new(message.from, encrypted)
      $stderr.puts "SENDING MESSAGE: #{msg}"
      $client.send(msg)
    end
  rescue Exception
    p $!, *$@
  end
end

puts "Ready"
puts @userstate.secure?.inspect
Thread.current.join
