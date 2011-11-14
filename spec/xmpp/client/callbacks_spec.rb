
require 'spec_helper'

describe XMPP::Client::Callbacks do
  describe '#add' do
    before do
      @arguments = [:message]
      @block = ->(msg) { }
    end

    it "returns a unique id" do
      id = execute
      # second call
      execute.should_not eq id
    end
  end

  describe '#once' do
    before do
      @arguments = [:message]
      @block = ->(msg) {}
    end

    it "adds a callback" do
      subject.should_receive(:add) { |type, block|
        type.should eq :message
      }
      execute
    end

    it "removes the callback, once it was called" do
      id = 'message-765'
      block = nil
      subject.should_receive(:add) { |type, &b|
        type.should eq :message
        block = b
        id
      }
      execute
      subject.should_receive(:remove).with(id)
      block.call('foo')
    end
  end


  describe '#call' do
    before do
      subject.add(:message)  { |arg| @m1_called = arg }
      subject.add(:message)  { |arg| @m2_called = arg }
      subject.add(:presence) { |arg| @p1_called = arg }
      subject.add(:presence) { |arg| @p2_called = arg }
      @arguments = [:message]
    end

    it "calls the callbacks for the given type" do
      execute(:message, 'foo')
      @m1_called.should eq 'foo'
      @m2_called.should eq 'foo'
    end

    it "doesn't call all the other callbacks" do
      execute(:message)
      @p1_called.should be_nil
      @p2_called.should be_nil
    end

  end

  describe '#remove' do
    before do
      @id = subject.add(:message) { |arg| @m_called = arg }
    end

    it "prevents the callback from being called again" do
      execute(@id)
      subject.call(:message, 'foo')
      @m_called.should be_nil
    end

    it "can be passed multiple IDs" do
      @id2 = subject.add(:presence) { |arg| @p_called = arg }
      execute(@id, @id2)
      subject.call(:message, 'foo')
      subject.call(:presence, 'bar')
      @m_called.should be_nil
      @p_called.should be_nil
    end
  end

end
