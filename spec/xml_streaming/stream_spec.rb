
require 'spec_helper'

describe XMLStreaming::Stream do
  subject {
    client = XMLStreaming::Client.allocate
    client.send(:initialize)
    described_class.new(client)
  }

  it "is a SAX Document" do
    subject.should be_a(Nokogiri::XML::SAX::Document)
  end

  it "has a stack, which is empty by default" do
    subject.stack.should_not be_nil
    subject.stack.should be_empty
  end


  describe '#start_element_namespace' do
    before do
      @arguments = ['foo']
    end

    element_behaviour = ->(*args) {
      it "initializes a new element" do
        XMLStreaming::Element.
          should_receive(:new).
          with('foo', {}, nil, nil, [])
        execute
      end

      it "pushes that element onto the stack" do
        execute
        subject.stack.last.should be_a(XMLStreaming::Element)
      end

      it "doesn't finalize the element" do
        execute
        subject.stack.last.should_not be_finalized
      end
    }

    describe "with no elements on the stack" do
      it "calls #root_opened on the client" do
        subject.client.should_receive(:root_opened)
        execute
      end

      instance_eval(&element_behaviour)
    end

    describe "with more than one element on the stack" do
      before do
        subject.start_element_namespace('stream')
        subject.start_element_namespace('message')
      end

      instance_eval(&element_behaviour)
    end

    describe 'with just one element on the stack' do
      before do
        subject.start_element_namespace('stream')
        @arguments = ['message']
      end

      it "initializes a new stanza" do
        XMLStreaming::Stanza.
          should_receive(:new).
          with('message', {}, nil, nil, [])
        execute
      end
    end
  end

  describe '#characters' do
    before do
      subject.start_element_namespace('foo')
      @element = subject.stack.last
    end

    it "feeds the given text to the last element on the stack" do
      @element.should_receive(:add_text).with('text')
      execute('text')
    end
  end

  describe '#end_element_namespace' do
    before do
      subject.start_element_namespace('stream')
      subject.start_element_namespace('message')
    end

    describe "with one element left on the stack" do
      before do
        @stanza = subject.stack.last
        @arguments = ['message']
      end

      it "calls #receive_stanza on the client" do
        subject.client.should_receive(:receive_stanza).with(@stanza)
        execute
      end
    end

    describe "with more than one element left on the stack" do
      before do
        subject.start_element_namespace('foo')
        @element = subject.stack.last
        @stanza = subject.stack[-2]
        @arguments = ['foo']
      end

      it "finalizes the element" do
        execute
        @element.should be_finalized
      end

      it "pops the element off the stack" do
        execute
        subject.stack.last.should_not eq @element
      end

      it "adds the element to the stanza's children" do
        @stanza.should_receive(:add_child).with(@element)
        execute
      end

      it "doesn't call #receive_stanza on the client" do
        subject.client.should_not_receive(:receive_stanza)
        execute
      end
    end
  end
end
