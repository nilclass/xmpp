
require 'spec_helper'

describe UI::Controller::Conversation do
  subject { described_class.new(@connection) }

  before do
    mock!('connection',
      :trigger => nil,
      :client => mock!('client',
        :jid => (@jid = XMPP::JID.new('hamlet@denmark.lit')),
        :message => mock!('message factory',
          :chat => nil,
          :register_conversation => nil
        )
      )
    )
  end


  describe '#start' do
    before do
      @arguments = [{ 'jid' => 'hamlet@denmark.lit' }]
    end

    it "triggers start_conversation" do
      @connection.should_receive(:trigger) { |evt, data|
        evt.should eq 'start_conversation'
        data[:jid].should eq XMPP::JID.new(@arguments[0]['jid'])
        data[:id].should be_a(String)
      }
      execute
    end

    it "remembers the conversation" do
      execute
      subject.conversation_for('hamlet@denmark.lit').should be_a(XMPP::Conversation)
    end

    it "registers the conversation with the message factory" do
      @message_factory.should_receive(:register_conversation)
      execute
    end
  end

  describe '#say' do
    before do
      @arguments = [{
          'to' => (@to = 'othello@venice.lit'),
          'body' => (@body = 'I think, therefore IM!')
        }]
    end

    it "sends a chat message with the given params" do
      @message_factory.should_receive(:chat).
        with(:to => @to, :body => @body)
      execute
    end
  end
end
