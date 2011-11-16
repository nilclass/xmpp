
class UI::Controller::Roster < UI::Controller::Base
  def load(*args)
    connection.client.iq.query('jabber:iq:roster') do |result|
      result.children.each do |item|
        connection.trigger('roster_item', :jid => item.attr(:jid))
      end
    end
  end
end
