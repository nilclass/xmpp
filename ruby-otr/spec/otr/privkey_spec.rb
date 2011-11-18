require 'spec_helper'

describe OTR::UserState do

  before(:each) { setup_files }
  after(:each) { teardown_files }
  
  context :read_privkey do

    it "should read existing privkey" do
      us = create_userstate("user1", "protocol", "keys_1.txt", "fingerprints_1.txt")
      us.read_privkey.should == true
    end

    it "should not read missing privkey" do
      us = create_userstate("user1", "protocol", "nonexistant.txt", "nonexistant.txt")
      us.read_privkey.should == false
    end

  end

  context :read_fingerprints do

    it "should read existing fingerprints" do
      us = create_userstate("user1", "protocol", "keys_1.txt", "fingerprints_1.txt")
      us.read_fingerprints.should == true
    end

    it "should not read missing fingerprints" do
      us = create_userstate("user1", "protocol", "nonexistant.txt", "nonexistant.txt")
      us.read_fingerprints.should == false
    end

  end

end



