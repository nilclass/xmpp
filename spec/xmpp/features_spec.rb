
require 'spec_helper'

describe XMPP::Features do
  is_a_stanza(:features)

  subject {
    described_class.new('features', {}, 'stream', nil, [])
  }

  describe '#starttls?' do
    it "returns true if a starttls child is available" do
      element = XMLStreaming::Element.
        new(
        'starttls',
        {},
        nil,
        'urn:ietf:params:xml:ns:xmpp-tls',
        [])
      subject.add_child(element)
      execute.should be_true
    end

    it "returns fals if no starttls child is available" do
      execute.should be_false
    end
  end

  describe "#mechanisms?" do
    it "returns true if a mechanisms child is available" do
      element = XMLStreaming::Element.
        new('mechanisms', {}, nil,
        'urn:ietf:params:xml:ns:xmpp-sasl', [])
      subject.add_child(element)
      execute.should be_true
    end
    it "returns false if no mechanisms child is available" do
      execute.should be_false
    end
  end

  describe "#mechanisms" do
    it "returns an Array of SASL mechanisms" do
      element = XMLStreaming::Element.
        new('mechanisms', {}, nil,
        'urn:ietf:params:xml:ns:xmpp-sasl', [])
      element.add_child(
                  XMLStreaming::Element.simple(
                                        'mechanism', 'PLAIN'))
      element.add_child(
                  XMLStreaming::Element.simple(
                                        'mechanism', 'DIGEST-MD5'))
      subject.add_child(element)
      execute.should eq ['PLAIN', 'DIGEST-MD5']
    end
  end
end
