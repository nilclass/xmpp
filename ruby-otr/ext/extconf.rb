require 'mkmf'

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']
RbConfig::MAKEFILE_CONFIG['CFLAGS'] = "-Wall"

extension_name = 'otr'
dir_config(extension_name)

have_header("ruby.h")
have_header("gcrypt.h")
have_library("otr")
have_header("libotr/proto.h")
have_header("libotr/userstate.h")
have_header("libotr/message.h")
have_header("libotr/privkey.h")
have_func("otrl_init", "libotr/proto.h")

create_makefile(extension_name)

makefile = File.read("Makefile")
File.open("Makefile", "w") do |f|
  f.write makefile.sub("-Wextra", "-Wall -Wextra -std=c99")
end
