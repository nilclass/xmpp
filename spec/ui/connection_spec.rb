
require 'spec_helper'

describe UI::Connection do
  it "is a websocket application" do
    described_class.ancestors.
      include?(Rack::WebSocket::Application).
      should be_true
  end

  subject do
    described_class.allocate.tap { |c|
      c.send(:initialize)
    }
  end

  it "has no client associated by default" do
    subject.client.should be_nil
  end

  describe '#trigger' do
    before do
      @arguments = ['my_event', { :foo => 'bar' }]
      subject.stub(:send_data)
    end

    it "sends a JSON string" do
      subject.should_receive(:send_data).
        with('{"event":"my_event","data":{"foo":"bar"}}')
      execute
    end
  end

  describe '#on_open'

  describe '#on_message' do
    before do
      @msg = '{"controller":"foo","action":"bar","arguments":["foo", "bar"]}'
      @msg_hash = JSON.load(@msg)
      @arguments = [mock!('env'), @msg]
      subject.stub(
              :controller => mock!('controller',
                     :call_action => nil)
              )
    end

    it "loads the message using JSON" do
      JSON.should_receive(:load).with(@msg).and_return(@msg_hash)
      execute
    end

    it "calls the appropriate controller and action" do
      subject.should_receive(:controller).with('foo')
      @controller.should_receive(:call_action).with('bar', "foo", "bar")
      execute
    end
  end

  describe "#controller" do
    before do
      UI::Controller.register(:foo, mock!('controller klass',
                                :new => mock!('controller')))
      @arguments = ['foo']
    end

    it "initializes the right controller klass" do
      @controller_klass.should_receive(:new).with(subject)
      execute.should eq @controller
    end
  end

  describe '#start_xmpp' do
    before do
      @arguments = ['hamlet@denmark.lit']
      XMPP::Client.stub(:connect => mock!('client'))
    end

    it "connects through XMPP::Client" do
      XMPP::Client.should_receive(:connect).
        with(subject, 'hamlet@denmark.lit')
      execute
    end

    it "sets the 'client' attribute" do
      execute
      subject.client.should eq @client
    end
  end
end
