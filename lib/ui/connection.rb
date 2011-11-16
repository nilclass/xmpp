
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
  rescue ControllerNotFound => exc
    trigger(:exception, :type => exc.class.name, :message => exc.message, :trace => exc.backtrace)
  end

  def on_close(env)
    client.close_connection if client
  end

  def trigger(event, data={})
    send_data(JSON.dump(:event => event.to_s, :data => data))
  end

  def controller(name)
    @controllers ||= {}
    return @controllers[name] if @controllers.has_key?(name)
    klass = UI::Controller.get(name)
    raise ControllerNotFound.new("No such controller: #{name}") unless klass
    instance = klass.new(self)
    @controllers[name] = instance
    return instance
  end

  def start_xmpp(jid)
    @client = XMPP::Client.connect(self, jid)
  end
end
