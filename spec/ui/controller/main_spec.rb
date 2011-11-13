
require 'spec_helper'

describe UI::Controller::Main do

  subject { described_class.new(@connection) }

  before do
    mock!('connection', :trigger => nil)
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
end
