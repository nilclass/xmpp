
require 'spec_helper'

describe XMPP::Client do
  it "inherits from XMLStreaming::Client" do
    described_class.superclass.should eq XMLStreaming::Client
  end

  describe '#initialize' do
    subject { described_class.allocate }

    before do
      @arguments = [mock!('ui'), 'hamlet@denmark.lit']
      subject.stub(:jump => nil)
    end

    it "sets the UI" do
      execute
      subject.ui.should eq @ui
    end

    it "sets the jid" do
      execute
      subject.jid.should be_a(XMPP::JID)
      subject.jid.to_s.should eq 'hamlet@denmark.lit'
    end

    it "can take a JID object" do
      execute(@ui, XMPP::JID.new('hamlet@denmark.lit'))
      subject.jid.to_s.should eq 'hamlet@denmark.lit'
    end

    it "jumps to the :init state" do
      subject.should_receive(:jump).with(:init)
      execute
    end

    it "sets up a SASL object" do
      XMPP::SASL.should_receive(:new).with(subject)
      execute
    end
  end

  subject {
    described_class.allocate.tap { |c|
      c.stub(:send_data) # won't work w/o EM running
      c.send(:initialize, mock!('ui'), 'hamlet@denmark.lit')
    }
  }

  describe "#receive_stanza" do
    before do
      @stanza = XMLStreaming::Stanza.
        new('message', {
              :from => 'hamlet@denmark.lit',
              :to => 'othello@venice.lit',
              :type => 'chat'
            }, nil, nil, [])
      @arguments = [@stanza]
    end

    it "calls the appropriate callbacks" do
      subject.callbacks.
        should_receive(:call).
        with(:message, @stanza)
      execute
    end

    it "logs the stanza" do
      subject.should_receive(:log).
        with(:receive, @stanza.to_s)
      execute
    end
  end

  describe '#callbacks' do
    it "is a Callbacks object" do
      execute.should be_kind_of(XMPP::Client::Callbacks)
    end
  end

  describe "#jump" do
    before do
      @arguments = [:foo]
      subject.stub(:on_foo => nil)
    end

    it "sets the state" do
      execute
      subject.state.should eq :foo
    end

    it "calls the on_:state callback" do
      subject.should_receive(:on_foo)
      execute
    end

    it "logs the old and new state" do
      subject.should_receive(:log).with(:state, "init -> foo")
      execute
      subject.should_receive(:log).with(:state, "foo -> bar")
      subject.stub(:on_bar => nil)
      execute(:bar)
    end

    handles_exceptions do
      @exception = RuntimeError.new("something happened")
      subject.stub(:on_foo).and_raise(@exception)
    end
  end

  describe '#unbind' do
    it "jumps to the :closed state" do
      subject.should_receive(:jump).with(:closed)
      execute
    end
  end

  describe "#on_init" do
    before do
      subject.stub(:jump) # this would call on_init beforehand
    end

    it "creates a stream element" do
      XMLStreaming::Element.
        should_receive(:new).
        with('stream', {
               :to => 'denmark.lit',
               :version => '1.0'
             }, 'stream', 'jabber:client', [
               ['stream', 'http://etherx.jabber.org/streams']
             ]
        ).and_return(mock!('element', :to_xml => nil))
      execute
    end

    it "sends the element's start tag down the line" do
      XMLStreaming::Element.stub(
                            :new => mock!(
                                   'element',
                                   :to_xml => '<data>'
                                   ))
      @element.should_receive(:to_xml).with(:start)
      subject.should_receive(:send_data).with('<data>')
      execute
    end
  end

  describe '#root_opened' do
    it "jumps to the :open state" do
      subject.should_receive(:jump).with(:open)
      execute
    end
  end

  describe '#on_open' do
    it "adds a one-shot callback for features" do
      subject.callbacks.should_receive(:once).with(:features)
      execute
    end

    it "calls #upgrade_stream as soon as the callback is called" do
      execute
      mock!('features')
      subject.should_receive(:upgrade_stream).with(@features)
      subject.callbacks.call(:features, @features)
    end
  end

  describe '#upgrade_stream' do
    before do
      @arguments = [mock!('features', :starttls? => false, :mechanisms? => false)]
    end

    it "negotiates tls if feature is given" do
      subject.should_not_receive(:negotiate_tls)
      execute
      @features.stub(:starttls? => true)
      subject.should_receive(:negotiate_tls)
      execute
    end

    describe "when determining mechanism" do

      before do
        @features.stub(
                  :mechanisms? => true,
                  :mechanisms => ['PLAIN', 'DIGEST-MD5', 'XOAUTH'])
        @auths = {
          'PLAIN' => mock!('plain authenticator',
            :params => {}),
          'DIGEST-MD5' => mock!('digest authenticator',
            :params => {})
        }
        subject.sasl.stub(:authenticator) { |mech|
          @auths[mech]
        }
        subject.ui.stub(:trigger)
      end

      it "tries to find a SASL authenticator for each mechanism" do
        subject.sasl.should_receive(:authenticator).
          with('PLAIN')
        subject.sasl.should_receive(:authenticator).
          with('DIGEST-MD5')
        subject.sasl.should_receive(:authenticator).
          with('XOAUTH')
        execute
      end

      it "fetches the params from each supported authenticator" do
        @plain_authenticator.should_receive(:params)
        @digest_authenticator.should_receive(:params)
        execute
      end

      it "triggers auth_params on the UI" do
        subject.ui.should_receive(:trigger) { |event, data|
          event.should eq :auth_params
          data[:params].should_not be_nil
        }
        execute
      end

      it "triggers auth_failure on the UI, if no authenticator is usable" do
        @features.stub(:mechanisms => ['XOAUTH'])
        subject.ui.should_receive(:trigger) { |event, data|
          event.should eq :auth_failure
          data[:message].should_not be_nil
        }
        execute
      end
    end
  end

  describe '#sasl' do
    it "is a XMPP::SASL object" do
      execute.should be_a(XMPP::SASL)
    end
  end

  describe '#ssl_handshake_completed' do
    it "calls post_init again" do
      subject.should_receive(:post_init)
      execute
    end

    it "jumps to the :init state" do
      subject.should_receive(:jump).with(:init)
      execute
    end
  end

  describe '#negotiate_tls' do
    before do
      subject # this calls Element.new as well :)
      XMLStreaming::Element.stub(:new => mock!('element'))
      subject.stub(:send_stanza)
    end

    it "creates a starttls element" do
      XMLStreaming::Element.should_receive(:new).
        with('starttls', {}, nil,
        'urn:ietf:params:xml:ns:xmpp-tls', [])
      execute
    end

    it "sends that element" do
      subject.should_receive(:send_stanza).with(@element)
      execute
    end

    it "sets up a callback for :proceed" do
      subject.callbacks.should_receive(:once).with(:proceed)
      execute
    end

    it "starts TLS once the callback is called" do
      execute
      subject.should_receive(:start_tls)
      subject.callbacks.call(:proceed, mock!('proceed'))
    end
  end

  describe '.connect' do
    before do
      @jid = XMPP::JID.new('hamlet@denmark.lit/behind-the-curtain')
      @arguments = [mock!('ui'), @jid]
      EM.stub(:connect)
      @jid.stub(:resolve_host => ['xmpp.denmark.lit', 5739])
    end

    it "can take the JID as a string" do
      jid = XMPP::JID.new('othello@venice.lit/foo')
      XMPP::JID.should_receive(:new).
        with('othello@venice.lit/foo').
        and_return(jid) # << why do I need this???
      execute(@ui, 'othello@venice.lit/foo')
    end

    it "resolves the appropriate host for the domain" do
      @jid.should_receive(:resolve_host)
      execute
    end

    it "initializes a EM connection" do
      EM.should_receive(:connect).with('xmpp.denmark.lit', 5739, described_class, @ui, @jid)
      execute
    end
  end

  describe '#bind_resource' do
    before do
      @callback = nil
      subject.iq.stub(:set) { |_, cb| @callback = cb }
      @result = XMLStreaming::Element.
        simple('bind', '', :xmlns => 'urn:ietf:params:xml:ns:xmpp-bind')
      @result.add_child(XMLStreaming::Element.simple('jid', 'hamlet@denmark.lit/behind-the-curtain'))

    end

    it "binds to resource" do
      subject.iq.should_receive(:set) { |element, callback|
        element.name.should eq 'bind'
        element.uri.should eq 'urn:ietf:params:xml:ns:xmpp-bind'
      }
      execute
    end

    it "resets the JID when getting a result" do
      execute
      @callback.call(@result)
      subject.jid.to_s.should eq 'hamlet@denmark.lit/behind-the-curtain'
    end

    it "jumps to :bound, when getting a result" do
      execute
      subject.should_receive(:jump).with(:bound)
      @callback.call(@result)
    end
  end

  describe '#iq' do
    it "is an IQFactory" do
      execute.should be_a(XMPP::IQFactory)
    end
  end
end
