#include "ruby-otr.h"

VALUE method_otr_init(VALUE self) {
  OTRL_INIT;
  return self;
}

VALUE method_otr_version(VALUE self) {
  return rb_str_new_cstr(otrl_version());
}
