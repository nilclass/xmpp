

#ifndef _LIBOTR_RUBY_H_
#define _LIBOTR_RUBY_H_

#include "ruby.h"

#include <libotr/proto.h>
#include <libotr/userstate.h>
#include <libotr/message.h>
#include <libotr/privkey.h>
#include <stdio.h>
#include <gcrypt.h>
#include <string.h>

VALUE method_otr_init(VALUE self);
VALUE method_otr_version(VALUE self);
VALUE method_userstate_initialize(VALUE self, VALUE account, VALUE protocol, VALUE keyfile, VALUE fingerprints);
VALUE method_userstate_read_privkey(VALUE self);
VALUE method_userstate_generate_privkey(VALUE self);
VALUE method_userstate_read_fingerprints(VALUE self);
VALUE method_userstate_write_fingerprints(VALUE self);
VALUE method_userstate_sending(VALUE self, VALUE to, VALUE text);
VALUE method_userstate_receiving(VALUE self, VALUE from, VALUE text);

OtrlUserState get_userstate(VALUE obj);

#endif
