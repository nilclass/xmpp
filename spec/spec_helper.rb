
require 'rubygems'
require 'rspec'

require File.expand_path("../../lib/xmpp.rb", __FILE__)

RSpec.configure do |config|
  Dir[File.expand_path("../support/**/*.rb", __FILE__)].each do |f|
    require(f)
  end

  config.include(MethodExecution)
  config.include(MockingHelper)
  config.extend(Shortcuts)
end
