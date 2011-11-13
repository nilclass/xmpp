
class UI::Connection < Rack::WebSocket::Application
  class ControllerNotFound < Exception
  end

  attr :client

  def on_open(env)
  end

  def on_message(env, data)
    message = JSON.load(data)
    controller(message['controller']).
      call_action(message['action'], *message['arguments'])
  rescue => exc
    $stderr.puts "#{exc.message} (#{exc.class.name})", *exc.backtrace
  end

  def trigger(event, data={})
    send_data(JSON.dump(:event => event.to_s, :data => data))
  end

  def controller(name)
    klass = UI::Controller.get(name)
    raise ControllerNotFound unless klass
    klass.new(self)
  end

  def start_xmpp(jid)
    @client = XMPP::Client.connect(self, jid)
  end
end
