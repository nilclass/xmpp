
require 'spec_helper'

describe UI::Controller::Roster do
  subject { described_class.new(@connection) }

  before do
    mock!('connection',
      :trigger => nil,
      :client => mock!('client',
        :jid => (@jid = XMPP::JID.new('hamlet@denmark.lit')),
        :iq => mock!('iq', :query => nil)
      )
    )
  end

  describe '#load' do

    it "sends an IQ query to load the roster" do
      @iq.should_receive(:query).with('jabber:iq:roster')
      execute
    end

    it "triggers a roster_item event for each returned roster item" do
      @iq.stub(:query) { |*args|
        @callback = args.last
      }
      execute
      result = XMLStreaming::Element.simple('query', '', :xmlns => 'jabber:iq:roster')
      result.add_child(XMLStreaming::Element.simple('item', '', :jid => 'othello@venice.lit'))
      result.add_child(XMLStreaming::Element.simple('item', '', :jid => 'gertrude@denmark.lit'))
      @connection.should_receive(:trigger).with('roster_item', :jid => 'othello@venice.lit')
      @connection.should_receive(:trigger).with('roster_item', :jid => 'gertrude@denmark.lit')
      @callback.call(result)
    end
  end
end
