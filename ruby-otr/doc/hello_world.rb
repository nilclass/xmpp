#!/usr/bin/env ruby

require "./lib/otr"


class OTR::UserState 
  #here we define callbacks that will be run when something occures
  def inject_message_cb from, message
    puts "\n\ninjecting message to #{from}  : #{message}\n\n"
    USERSTATES[from].receiving(@account, message)
  end

  def new_fingerprint_cb(accountname, protocol, buddy, fingerprint)
    puts "new fingerprint or it has changed since last encounter :"
    #puts "account  : #{account}"
    puts "protocol  : #{protocol}"
    puts "buddy  : #{buddy}"
    puts "fingerprint  : #{fingerprint.to_i}"
    puts "is this a valid fingerprint for this user ?[y/N]"
    if(gets=~/^[yYjJ]/)
       puts "ok"
     else
       puts "not ok inform the user"
     end
  end
  def write_fingerprints_cb sucess
    if sucess
      puts "Fingerprints successfully written to #{@fingerprint_file}"
    else
      puts "failed to write fingerprints to #{@fingerprint_file}"
    end
  end
  def secure_cb context
    puts "-------- secure  cb  ------------"
    puts context.inspect
    puts context.class
    puts (context.methods)
  end
end

OTR.init

u = OTR::UserState.new("user1", "protocol", "keys1.txt", "fingerprints1.txt")
u2 = OTR::UserState.new("user2", "protocol", "keys2.txt", "fingerprints2.txt")

USERSTATES = {"user1" => u, "user2" => u2}

u.generate_privkey  unless u.read_privkey
u2.generate_privkey  unless u2.read_privkey

u.read_fingerprints 
u2.read_fingerprints

m1 = u.sending("user2", "hallo");
puts "'#{u2.receiving("user1", m1);}'"

m2 = u2.sending("user1", "second message");
puts "m2  = '#{m2}'"
puts "'#{u.receiving("user2", m2);}'"

