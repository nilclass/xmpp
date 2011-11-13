
class UI::Controller::Main < UI::Controller::Base
  def connect(jid, *args)
    trigger('connecting', :jid => jid)
    connection.start_xmpp(jid)
  end
end
