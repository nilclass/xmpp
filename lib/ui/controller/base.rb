class UI::Controller::Base
  def self.inherited(base)
    name = base.name.split('::').last.gsub(/([a-z0-9])([A-Z])/) {
      $~[1] + '_' + $~[2]
    }.downcase
    UI::Controller.register(name, base)
  end

  attr :connection

  def initialize(connection)
    @connection = connection
  end

  def call_action(name, *args)
    send(name, *args)
  rescue => exc
    trigger(:exception, :type => exc.class.name, :message => exc.message, :trace => exc.backtrace)
  end

  def trigger(*args)
    connection.trigger(*args)
  end
end
