class UI::Controller::Base
  def self.inherited(base)
    name = base.name.split('::').last.gsub(/([a-z0-9])([A-Z])/) {
      $~[1] + '_' + $~[2]
    }.downcase
    UI::Controller.register(name, base)
  end
end
