require 'rack/websocket'
require 'json'
require 'sinatra'
require 'coffee-script'

module UI
  root = File.expand_path("../ui/", __FILE__)
  require "#{root}/http.rb"
  require "#{root}/connection.rb"
  require "#{root}/controller.rb"
  require "#{root}/controller/base.rb"
  require "#{root}/controller/main.rb"

end
