
require 'spec_helper'

describe XMPP::MessageFactory do
  subject { described_class.new(@client) }

  before do
    mock!('client',
      :send_stanza => nil,
      :jid => XMPP::JID.new('hamlet@denmark.lit'),
      :callbacks => XMPP::Client::Callbacks.new,
      :ui => mock!('ui',
        :trigger => nil))
  end

  describe '.new' do
    before do
      @arguments = [@client]
    end

    it "sets the client" do
      execute.client.should eq @client
    end

    it "sets up a message callback" do
      @client.callbacks.should_receive(:add).with(:message)
      execute
    end
  end

  describe 'the message callback' do
    before do
      @msg = XMLStreaming::Element.simple('message', '',
        :type => 'chat', :from => 'othello@venice.lit')
      @msg.add_child(XMLStreaming::Element.simple('body', 'foo'))
      @conversation = XMPP::Conversation.new('othello@venice.lit')
      subject # needs to be mentioned, to be initialized
    end

    it "triggers a chat_message event, when a chat message is received" do
      @ui.should_receive(:trigger).with(
        :chat_message,
        :body => 'foo',
        :from => 'othello@venice.lit',
        :id => nil)
      @client.callbacks.call(:message, @msg)
    end

    it "injects the message in a conversation, if one is registered" do
      @conversation.should_receive(:received_message)
      subject.register_conversation(@conversation)
      @client.callbacks.call(:message, @msg)
    end

    it "contains the message ID in the UI event, if one is registered" do
      @ui.should_receive(:trigger) { |evt, data|
        data[:id].should eq @conversation.id
      }
      subject.register_conversation(@conversation)
      @client.callbacks.call(:message, @msg)
    end
  end

  describe '#register_conversation' do
    it "doesn't fail" do
      conversation = XMPP::Conversation.new('othello@venice.lit')
      execute(conversation)
    end
  end


  describe '#chat' do
    before do
      @arguments = [{ :to => 'othello@venice.lit', :body => 'foobar' }]
    end

    it "it sends a chat message" do
      @client.should_receive(:send_stanza) { |stanza|
        stanza.name.should eq 'message'
        stanza.children.first.name.should eq 'body'
        stanza.children.first.text.should eq 'foobar'
        stanza.attr(:to).should eq 'othello@venice.lit'
        stanza.attr(:type).should eq 'chat'
      }
      execute
    end
  end
end
