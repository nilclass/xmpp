
require 'spec_helper'

describe XMPP::SASL::Authenticator::Plain do
  # send <auth mechanism="plain" xmlns="urn:ietf:params:xml:ns:xmpp-sasl" text="..."/>
  # text is: Base64.encode64("\0#{jid.local_name}\0#{password}")

  describe "#params" do
    pending "returns :password => 'Password'"
  end

  describe "#run" do
    pending "sends <auth/>"

    describe "on positive reply" do
      pending "triggers :auth_success"
    end

    describe "on negative reply" do
      pending "triggers :auth_failure"
    end
  end
end
