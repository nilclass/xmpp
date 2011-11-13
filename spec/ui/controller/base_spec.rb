
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
end
