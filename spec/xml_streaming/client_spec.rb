
require 'spec_helper'

describe XMLStreaming::Client do
  subject {
    client = described_class.allocate
    client.send(:initialize)
    client
  }

  it "is a EventMachine::Connection" do
    subject.should be_a(EventMachine::Connection)
  end

  describe '#post_init' do
    it "initializes a stream, passing itself" do
      XMLStreaming::Stream.should_receive(:new).with(subject)
      execute
    end

    it "initializes a push parser" do
      Nokogiri::XML::SAX::PushParser.should_receive(:new)
      execute
    end

    handles_exceptions do
      @exception = RuntimeError.new("FOO")
      Nokogiri::XML::SAX::PushParser.stub(:new).
        and_raise(@exception)
    end
  end

  describe '#receive_data' do
    before do
      subject.post_init
      @arguments = ['<data/>']
    end

    it "passes the data to the push parser" do
      subject.parser.should_receive(:<<).with('<data/>')
      execute
    end

    handles_exceptions do
      @exception = RuntimeError.new('foobar')
      subject.parser.stub(:<<).and_raise(@exception)
    end
  end

  describe '#send_stanza' do
    it "passes the stanza on to send_data as XML" do
      stanza = XMLStreaming::Stanza.new('foo', { :bar => 'baz' }, nil, nil, [])
      stanza.add_child(XMLStreaming::Stanza.new('bar', {}, nil, nil, []))
      subject.should_receive(:send_data).with('<foo bar="baz"><bar></bar></foo>')
      execute(stanza)
    end
  end

  describe '#receive_stanza' do
    before do
      @arguments = [mock!('stanza')]
    end

    it "does nothing by default" do
      execute
    end
  end

  describe '#root_opened' do
    it "does nothing by default" do
      execute
    end
  end

  describe '#log' do
    it "outputs the given message with the type in upper case" do
      $stdout.should_receive(:puts).with("FOO: bar")
      execute(:foo, 'bar')
    end
  end
end
