
require 'spec_helper'

describe XMPP::SASL::Authenticator do
  describe '.new' do
    before do
      @arguments = [mock!('client')]
    end

    it "sets the client" do
      execute.client.should eq @client
    end
  end
end
