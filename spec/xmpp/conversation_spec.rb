
require 'spec_helper'

describe XMPP::Conversation do
  subject { described_class.new(@jid) }

  before do
    @jid = XMPP::JID.new('hamlet@denmark.lit')
  end

  describe '.new' do
    before do
      @arguments = [@jid]
    end

    it "sets the JID" do
      execute.jid.should eq @jid
    end

    it "casts the JID" do
      execute('othello@venice.lit').jid.should be_a(XMPP::JID)
    end
  end

  describe '#received_message' do
    pending "persists the message"
  end

  describe '#sent_message' do
    pending "persists the message"
  end

  describe '#filter_incoming' do
    pending "applies OTR and stuff"
  end

  describe '#filter_outgoing' do
    pending "applies OTR and stuff"
  end
end
