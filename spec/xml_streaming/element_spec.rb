
require 'spec_helper'

describe XMLStreaming::Element do
  subject {
    described_class.new('bar', { :foo => 'bar' }, 'foo', 'uri', [[nil, 'uri'], ['my-prefix', 'my-ns']])
  }

  describe '.new' do
    before do
      @arguments = [
        'bar',             # name
        { :foo => 'bar' }, # attrs
        'foo',             # prefix
        'uri',             # uri
        []                 # ns
      ]
    end

    it "sets the name" do
      execute.name.should eq 'bar'
    end

    it "sets the prefix" do
      execute.prefix.should eq 'foo'
    end

    it "sets the attributes" do
      execute.attributes.should eq(:foo => 'bar')
    end

    it "sets the uri" do
      execute.uri.should eq 'uri'
    end

    it "sets the namespaces" do
      execute.namespaces.should eq []
    end

    it "initializes the text" do
      execute.text.should be_a(String)
    end

    it "initializes the children" do
      execute.children.should be_a(Array)
    end
  end

  describe '#finalize!' do
    it "finalizes the element" do
      subject.should_not be_finalized
      execute
      subject.should be_finalized
    end
  end

  describe '#add_text' do
    it "appends the given text to the element's text" do
      execute('foo')
      subject.text.should eq 'foo'
      execute('bar')
      subject.text.should eq 'foobar'
    end
  end

  describe '#add_child' do
    before do
      @element = subject.clone
      @arguments = [@element]
    end

    it "adds the given element to the list of children" do
      execute
      subject.children.last.should eq @element
    end
  end

  describe '#to_xml' do
    subject { described_class.new('bar', { :foo => 'bar', :baz => 'sup"e"r' }, 'foo', 'uri', [[nil, 'uri'], ['my-prefix', 'my-ns']]) }

    it "works correctly" do
      execute.should eq '<foo:bar foo="bar" baz="sup\"e\"r" xmlns="uri" xmlns:my-prefix="my-ns"></foo:bar>'
    end

    it "can also just generate the start tag" do
      execute(:start).should eq '<foo:bar foo="bar" baz="sup\"e\"r" xmlns="uri" xmlns:my-prefix="my-ns">'
    end

    it "can also just generate the end tag" do
      execute(:end).should eq '</foo:bar>'
    end
  end

  describe '#all_attributes' do
    it "includes the attributes" do
      execute[:foo].should eq 'bar'
    end

    it "includes the namespace URI" do
      execute[:xmlns].should eq 'uri'
    end

    it "includes all the namespaces" do
      execute['xmlns:my-prefix'.to_sym].should eq 'my-ns'
    end
  end
end
