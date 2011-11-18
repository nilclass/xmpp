require 'spec_helper'

describe OTR do

  it "should init" do
    OTR::init.should == OTR
  end

  it "should get version" do
    OTR::version.should == "3.2.0"
  end

end
