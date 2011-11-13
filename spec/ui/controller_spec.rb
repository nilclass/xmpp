
require 'spec_helper'

describe UI::Controller do
  describe '.register' do
    before do
      @arguments = ['foo', mock!('controller klass')]
    end

    it "adds a controller klass to the list" do
      execute
      described_class.get('foo').should eq @controller_klass
    end
  end

  describe '.get' do
    before do
      described_class.register('foo', mock!('controller klass'))
      @arguments = ['foo']
    end

    it "returns the previously registered controller" do
      execute.should eq @controller_klass
    end

    it "works with a symbol as well as a string" do
      execute.should eq execute(:foo)
    end
  end
end
