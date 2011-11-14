require 'resolv'

require File.expand_path("../xml_streaming.rb", __FILE__)
require File.expand_path("../ui.rb", __FILE__)

module XMPP
  root = File.expand_path("../xmpp/", __FILE__)
  require "#{root}/jid.rb"
  require "#{root}/message.rb"
  require "#{root}/features.rb"
  require "#{root}/client.rb"
  require "#{root}/client/callbacks.rb"
  require "#{root}/sasl.rb"
  require "#{root}/sasl/authenticator.rb"
  require "#{root}/sasl/authenticator/plain.rb"
end
