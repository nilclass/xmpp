require File.join(File.expand_path(File.dirname(__FILE__)), "../ext/otr")

module OTR
  module Policy
    
    ALLOW_V1 = 1
    ALLOW_V2 = 2
    REQUIRE_ENCRYPTION = 4
    SEND_WHITESPACE_TAG = 8
    WHITESPACE_START_AKE = 16
    ERROR_START_AKE = 32
    VERSION_MASK = 3
    NEVER = 0
    OPPORTUNISTIC = 59
    MANUAL = 3
    ALWAYS = 55
    DEFAULT = 59

  end

  class UserState

    attr_reader :account, :protocol, :key_file, :fingerprint_file
 
#   def initialize *args
#      @secure = false
#      puts "initialized"
#      super *args
#    end

    def method_missing(name, *args)
      if name.to_s =~ /_cb$/
        puts "#{name} called"
      else
        super(name, *args)
      end
    end
 
   def policy_cb *args
     return OTR::Policy::DEFAULT
   end

    def secure?
      return @secure;
    end

  end

end
