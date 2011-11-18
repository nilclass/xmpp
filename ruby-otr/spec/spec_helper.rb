require 'fileutils'
require 'rspec'

require './lib/otr'

def create_userstate account, protocol, key_file, fingerprint_file
  key_file = "./spec/tmp/#{key_file}"
  fingerprint_file = "./spec/tmp/#{fingerprint_file}"
  OTR::UserState.new(account, protocol, key_file, fingerprint_file)
end

def exchange_message(from, to, message)
  send = from.sending(to.account, message)
  recv = to.receiving(from.account, send)
  return send, recv
end


def setup_files
  FileUtils.mkdir_p("./spec/tmp")
  FileUtils.cp("./spec/fixtures/keys_1.txt", "./spec/tmp/keys_1.txt")
  FileUtils.cp("./spec/fixtures/keys_2.txt", "./spec/tmp/keys_2.txt")
  FileUtils.cp("./spec/fixtures/fingerprints_1.txt", "./spec/tmp/fingerprints_1.txt")
end

def teardown_files
  FileUtils.rm_rf("./spec/tmp")
end

OTR::init
