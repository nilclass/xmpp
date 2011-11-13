module Shortcuts
  def handles_exceptions(&block)
    describe "exceptions" do
      before(&block)
      before do
        subject.stub(:log_exception)
      end

      it "are caught" do
        -> { execute }.should_not raise_exception
      end

      it "are logged" do
        subject.should_receive(:log_exception).with(@exception)
        execute
      end
    end
  end

  def is_a_stanza(type)
    it "is a XMLStreaming Stanza" do
      described_class.ancestors.
        include?(XMLStreaming::Stanza).should be_true
    end

    it "is registered as :#{type}" do
      XMLStreaming::Stanza.
        registered_subclasses[type.to_sym].
        should eq described_class
    end
  end

end
