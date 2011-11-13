
require 'eventmachine'
require 'nokogiri'

module XMLStreaming
  root = File.expand_path("../xml_streaming/", __FILE__)
  require "#{root}/client.rb"
  require "#{root}/stream.rb"
  require "#{root}/element.rb"
  require "#{root}/stanza.rb"
end
