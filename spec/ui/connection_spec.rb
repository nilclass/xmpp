
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

  describe '#on_open'

  describe '#on_message' do
    before do
      @msg = '{"controller":"foo","action":"bar","arguments":["foo", "bar"]}'
      @msg_hash = JSON.load(@msg)
      @arguments = [mock!('env'), @msg]
      subject.stub(
              :controller => mock!('controller',
                     :bar => nil)
              )
    end

    it "loads the message using JSON" do
      JSON.should_receive(:load).with(@msg).and_return(@msg_hash)
      execute
    end

    it "calls the appropriate controller and action" do
      subject.should_receive(:controller).with('foo')
      @controller.should_receive(:bar).with("foo", "bar")
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
end
