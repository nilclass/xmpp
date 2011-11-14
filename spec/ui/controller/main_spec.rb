
require 'spec_helper'

describe UI::Controller::Main do

  subject { described_class.new(@connection) }

  before do
    mock!('connection',
      :trigger => nil,
      :client => mock!('client',
        :jid => (@jid = XMPP::JID.new('hamlet@denmark.lit')),
        :sasl => mock!('sasl',
          :authenticator => nil)))

  end

  describe '#connect' do
    before do
      @arguments = ['hamlet@denmark.lit']
      @connection.stub(:start_xmpp)
    end

    it "triggers the 'connecting' event" do
      subject.should_receive(:trigger).
        with('connecting', :jid => 'hamlet@denmark.lit')
      execute
    end

    it "calls 'start_xmpp' on the connection" do
      @connection.should_receive(:start_xmpp).with('hamlet@denmark.lit')
      execute
    end
  end

  describe '#auth' do
    before do
      @arguments = [{
          'mechanism' => 'PLAIN',
          'params' => {
            'password' => 'foo'
          }
        }]
      subject.connection.client.sasl.
        stub(:authenticator => mock!('authenticator', :run => nil))
    end

    it "gets the authenticator" do
      subject.connection.client.sasl.should_receive(:authenticator).
        with('PLAIN')
      execute
    end

    it "runs the authenticator" do
      @authenticator.should_receive(:run).
        with(:jid => @jid, :password => 'foo')
      execute
    end
  end
end

