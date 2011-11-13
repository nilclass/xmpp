require 'rack/websocket'
require 'json'

module UI
  root = File.expand_path("../ui/", __FILE__)
  require "#{root}/connection.rb"
  require "#{root}/controller.rb"
  require "#{root}/controller/base.rb"

end
