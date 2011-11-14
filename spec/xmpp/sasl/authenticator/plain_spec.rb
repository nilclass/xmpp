
require 'spec_helper'

describe XMPP::SASL::Authenticator::Plain do
  # send <auth mechanism="plain" xmlns="urn:ietf:params:xml:ns:xmpp-sasl" text="..."/>
  # text is: Base64.encode64("\0#{jid.local_name}\0#{password}")

  subject { described_class.new(@client) }

  before do
    mock!('client',
      :callbacks => XMPP::Client::Callbacks.new,
      :ui => mock!('ui'))
  end

  describe "#params" do
    it "returns :password => 'Password'" do
      execute.should eq(:password => 'Password')
    end
  end

  describe "#run" do
    before do
      @arguments = [{
          :password => 'foo',
          :jid => XMPP::JID.new('hamlet@denmark.lit')
        }]
      @client.stub(:send_stanza)
    end

    it "initializes a <auth/> Element" do
      XMLStreaming::Element.should_receive(:new).and_return(mock!('stanza', :add_text => nil))
      execute
    end

    it "encodes the JID's local_part and password as Base64" do
      Base64.should_receive(:encode64).
        with("\0hamlet\0foo").and_return('foo')
      execute
    end

    it "sends the <auth/> element, with the right mechanism, namespace and text set" do
      Base64.stub(:encode64 => 'encoded-auth-string')
      subject.client.should_receive(:send_stanza) { |stanza|
        attrs = stanza.attributes
        attrs[:mechanism].should eq 'PLAIN'
        stanza.uri.should eq 'urn:ietf:params:xml:ns:xmpp-sasl'
        stanza.text.should eq 'encoded-auth-string'
      }
      execute
    end

    describe "on positive reply" do
      before do
        @stanza = XMLStreaming::Element.simple('success')
        subject.run(*@arguments) # don't use execute, it will clear the stubs
      end

      it "makes the client jump to the :auth state" do
        @client.should_receive(:jump).with(:auth)
        @client.callbacks.call(:success, @stanza)
      end
    end

    describe "on negative reply" do
      before do
        @stanza = XMLStreaming::Element.simple('failure')
        @stanza.add_child(XMLStreaming::Element.simple('not-authorized'))
        subject.run(*@arguments) # don't use execute, it will clear the stubs
      end

      it "triggers :auth_failure" do
        @ui.should_receive(:trigger) { |evt, data|
          evt.should eq :auth_failure
          data[:message].should_not be_nil
        }
        @client.callbacks.call(:failure, @stanza)
      end
    end
  end
end
