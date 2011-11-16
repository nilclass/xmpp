
require 'sinatra'

class Styleguide < Sinatra::Base
  set :views, File.expand_path('../style/', __FILE__)

  get '/' do
    haml :index
  end

  get '/:widget' do |widget|
    haml widget.to_sym
  end
end
