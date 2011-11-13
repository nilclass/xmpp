
require 'spec_helper'

describe UI::Controller::Base do
  it "registered the subclass, when inheriting" do
    UI::Controller.should_receive(:register) { |name, klass|
      name.should eq 'foo_bar'
      klass.name.should eq 'FooBar'
      klass.superclass.should eq UI::Controller::Base
    }
    class FooBar < described_class
    end
  end

  describe '.new' do
    before do
      @arguments = [mock!('connection')]
    end

    it "sets the connection attribute" do
      execute.connection.should eq @connection
    end
  end

  subject { described_class.new(@connection) }

  before do
    mock!('connection')
  end

  describe "#trigger" do
    before do
      @arguments = ['foo', :foo => 'bar']
    end

    it "is passed on to the connection" do
      @connection.should_receive(:trigger).
        with(*@arguments)
      execute
    end
  end

  describe '#call_action' do
    before do
      @arguments = ['foo', 'bar']
      subject.stub(:foo => nil)
    end

    it "calls the given method" do
      subject.should_receive(:foo).with('bar')
      execute
    end

    it "propagates exceptions through the 'exception' event" do
      exception = RuntimeError.new("FooBar")
      exception.stub(:backtrace => ['back', 'trace'])
      subject.stub(:foo).and_raise(exception)
      subject.should_receive(:trigger).
        with(:exception,
        :type => "RuntimeError",
        :message => "FooBar",
        :trace => ['back', 'trace'])
      execute
    end
  end
end
