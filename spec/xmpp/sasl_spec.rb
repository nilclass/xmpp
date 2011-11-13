
require 'spec_helper'

describe XMPP::SASL do
  describe '.register' do
    before do
      class TestAuthenticator < XMPP::SASL::Authenticator
      end
      @arguments = ['TEST', TestAuthenticator]
    end

    it "adds the given authenticator to the list" do
      execute
      described_class.authenticators['TEST'].
        should eq TestAuthenticator
    end
  end

  subject {
    described_class.new(@client)
  }

  before do
    mock!('client')
  end

  describe '.new' do
    it "sets the client" do
      execute(mock!('client'))
      subject.client.should eq @client
    end
  end

  describe '#authenticator' do
    before do
      class TestAuthenticator < XMPP::SASL::Authenticator
      end

      described_class.register('TEST', TestAuthenticator)
    end

    it "returns a new authenticator, if one is registered for the given mechanism" do
      TestAuthenticator.should_receive(:new).with(@client)
      execute('TEST')
    end

    it "returns nil if the mechanism isn't supported" do
      execute('SOMETHING-ELSE')
    end
  end
end
