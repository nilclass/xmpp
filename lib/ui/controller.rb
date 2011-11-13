module UI::Controller
  def self.register(name, klass)
    registered_controllers[name.to_sym] = klass
  end

  def self.get(name)
    registered_controllers[name.to_sym]
  end

  private

  def self.registered_controllers
    @registered_controllers ||= {}
  end
end
