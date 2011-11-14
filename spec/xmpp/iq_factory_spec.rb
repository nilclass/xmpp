
require 'spec_helper'

describe XMPP::IQFactory do
  subject { described_class.new(@client) }

  before do
    mock!('client',
      :send_stanza => nil,
      :jid => XMPP::JID.new('hamlet@denmark.lit'),
      :callbacks => XMPP::Client::Callbacks.new)
  end

  describe '.new' do
    before do
      @arguments = [@client]
    end

    it "sets the client" do
      execute.client.should eq @client
    end

    it "sets up an IQ callback" do
      @client.callbacks.should_receive(:add).with(:iq)
      execute
    end
  end

  describe '#set' do
    it "sends an empty IQ:set stanza" do
      @client.should_receive(:send_stanza) { |stanza|
        stanza.name.should eq 'iq'
        stanza.type.should eq 'set'
        stanza.attributes[:id].should_not be_nil
        stanza.attributes[:from].should eq @client.jid.to_s
        stanza.attributes[:to].should be_nil
      }
      execute
    end

    describe 'with a block given' do
      before do
        @block = ->(result) { @result = result }
        @client.stub(:send_stanza) { |stanza|
          @id = stanza.attributes[:id]
        }
      end

      it "calls the block with the result, if receiving a result" do
        subject.set(&@block)
        iq = XMLStreaming::Element.simple('iq', '', :type => 'result', :id => @id)
        iq.add_child(result = XMLStreaming::Element.simple('foo', 'bar'))
        @client.callbacks.call(:iq, iq)
        @result.should eq result
      end
    end
  end
end
