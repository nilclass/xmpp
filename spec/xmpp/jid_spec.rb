
require 'spec_helper'

describe XMPP::JID do
  describe '.new' do
    before do
      @instance = execute('hamlet@denmark.lit/behind-the-curtain')
    end

    it "sets the local_part" do
      @instance.local_part.should eq 'hamlet'
    end

    it "sets the hostname" do
      @instance.hostname.should eq 'denmark.lit'
    end

    it "sets the resource" do
      @instance.resource.should eq 'behind-the-curtain'
    end
  end

  subject { described_class.new(@orig = 'othello@venice.lit/foo') }

  describe "#to_s" do
    it "returns the original JID" do
      execute.should eq @orig
    end
  end

  describe "#resolve_host" do
    before do
      Resolv::DNS.
        stub(
        :new => mock!('resolver',
               :getresource => mock!('resource',
                 :target => mock!('target',
                   :to_s => 'xmpp.venice.lit'
                   ),
                 :port => 5789
                 )
               )
        )
    end

    it "creates a new resolver" do
      Resolv::DNS.should_receive(:new)
      execute
    end

    it "attempts to resolve the xmpp-client tcp service" do
      @resolver.should_receive(:getresource).
        with("_xmpp-client._tcp.venice.lit",
        Resolv::DNS::Resource::IN::ANY)
      execute
    end

    it "returns the target host and port" do
      @target.should_receive(:to_s)
      execute.should eq ['xmpp.venice.lit', 5789]
    end

    it "returns the domain itself, with the default port, in case of a ResolvError" do
      @resolver.stub(:getresource).and_raise(Resolv::ResolvError.new)
      execute.should eq ['venice.lit', 5222]
    end

  end
end
