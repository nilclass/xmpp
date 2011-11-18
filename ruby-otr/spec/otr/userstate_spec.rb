require 'spec_helper'

describe OTR::UserState do

  before(:each) { setup_files }
  after(:each) { teardown_files }
  
  it "should initialize" do
    us = create_userstate("user1", "protocol", "keys_1.txt", "fingerprints_1.txt")
    us.should be_a(OTR::UserState)
    us.account.should == "user1"
    us.protocol.should == "protocol"
    us.key_file.should =~ /keys_1.txt/
    us.fingerprint_file.should =~ /fingerprints_1.txt/
  end

  context :communication do

    before :each do
      $us1 = create_userstate("user1", "protocol", "keys_1.txt", "fingerprints_1.txt")
      $us2 = create_userstate("user2", "protocol", "keys_2.txt", "fingerprints_2.txt")
      $us1.read_privkey
      $us2.read_privkey
    end
    
    context :handshake do
      
      it "should add padding to first message" do
        send, recv = exchange_message($us1, $us2, "test message")
        send.should == "test message \t  \t\t\t\t \t \t \t   \t \t  \t   \t\t  \t "
        recv.should == "test message"
      end
      
      it "should inject handshake initiation upon receiving padded message" do
        $us2.should_receive(:inject_message_cb).with("user1", /\?OTR:/)
        send, recv = exchange_message($us1, $us2, "test message")
      end
      
      it "should inject handshake acknowledgement upon receiving initiation" do
        def $us2.inject_message_cb(to, message)
          $us1.receiving("user2", message).should == nil
        end
        $us1.should_receive(:inject_message_cb).with("user2", /\?OTR:/)
        send, recv = exchange_message($us1, $us2, "test message")
      end
      
    end

    context :encryption do

      before :each do
        def $us1.inject_message_cb(to, message)
          $us2.receiving("user1", message)
        end
        def $us2.inject_message_cb(to, message)
          $us1.receiving("user2", message)
        end
      end

      it "should warn that first message after handshake was not encrypted" do
        send, recv = exchange_message($us1, $us2, "test message")
        recv.should == "<b>The following message received from user1 was <i>not</i> encrypted: [</b>test message<b>]</b>"
      end
      
      it "should encrypt subsequent messages from user1 to user2" do
        exchange_message($us1, $us2, "handshake")

        send, recv = exchange_message($us1, $us2, "test message")
        send.should =~ /\?OTR/
        recv.should == "test message"
      end

      it "should encrypt subsequent messages from user2 to user1" do
        exchange_message($us1, $us2, "handshake")

        send, recv = exchange_message($us2, $us1, "test message")
        send.should =~ /\?OTR:/
        recv.should == "test message"
      end

      context :fingerprints do
        
        it "should receive new_fingerprint_cb when completing handshake the first time" do
          $us1.should_receive(:new_fingerprint_cb).with("user1", "protocol", "user2", /.*?/)
          exchange_message($us1, $us2, "test message")
        end

        it "should write fingerprints" do
          def $us1.new_fingerprint_cb *args
            write_fingerprints.should == true
          end
          exchange_message($us1, $us2, "test message")
          File.exist?('./spec/tmp/fingerprints_1.txt').should == true
        end
        
      end
      
    end

  end
  
end
