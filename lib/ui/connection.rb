
class UI::Connection < Rack::WebSocket::Application
  attr :client

  def on_open
  end

  def on_message(env, data)
    message = JSON.load(data)
    controller(message['controller']).
      send(message['action'], *message['arguments'])
  end

  def controller(name)
    klass = UI::Controller.get(name)
    klass.new(self)
  end
end
