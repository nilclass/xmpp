require 'resolv'
require 'pathname'

require File.expand_path("../xml_streaming.rb", __FILE__)
require File.expand_path("../ui.rb", __FILE__)
require File.expand_path("../../doc/styleguide.rb", __FILE__)

require File.expand_path("../../ruby-otr/lib/otr.rb", __FILE__)


module XMPP
  root = File.expand_path("../xmpp/", __FILE__)
  require "#{root}/jid.rb"
  require "#{root}/message.rb"
  require "#{root}/features.rb"
  require "#{root}/client.rb"
  require "#{root}/client/callbacks.rb"
  require "#{root}/client/otr.rb"
  require "#{root}/sasl.rb"
  require "#{root}/sasl/authenticator.rb"
  require "#{root}/sasl/authenticator/plain.rb"
  require "#{root}/iq_factory.rb"
  require "#{root}/message_factory.rb"
  require "#{root}/conversation.rb"

  class << self
    def root
      @root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
