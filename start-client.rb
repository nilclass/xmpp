#!/usr/bin/env ruby

require 'thin'

require './lib/xmpp'

if EM::VERSION < "1.0.0"
  ::Thin::Server.const_set 'DEFAULT_TIMEOUT', 0
end


EM.run do
  builder = Rack::Builder.new do
    map '/socket' do
      run UI::Connection.new :backend => { :debug => true }
    end

    map '/' do
      run UI::HTTP
    end
  end
  thin = Thin::Server.new(builder.to_app, 3000)
  thin.start!
end
