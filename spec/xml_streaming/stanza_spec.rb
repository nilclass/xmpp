
require 'spec_helper'

describe XMLStreaming::Stanza do
  subject {
    @attrs = { :from => 'foo', :to => 'bar', :type => 'baz' }
    described_class.new('message', @attrs, nil, nil, [])
  }

  it "is a Element" do
    described_class.ancestors.include?(XMLStreaming::Element).should be_true
  end

  %w(from to type).each do |attr|
    describe "##{attr}" do
      it "gives direct access to the #{attr} attribute" do
        execute.should eq @attrs[attr.to_sym]
      end
    end
  end

  describe '.new' do
    before do
      @arguments = ['message', {}, nil, nil, []]
    end

    it "instantiates an appropriate child class" do
      execute.should be_a(XMPP::Message)
    end
  end
end
