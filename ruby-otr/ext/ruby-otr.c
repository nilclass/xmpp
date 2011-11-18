#include "ruby-otr.h"

void Init_otr();

VALUE otr = Qnil;

void Init_otr() {
  VALUE m_otr = Qnil;
  VALUE c_otr_userstate = Qnil;
  m_otr = rb_define_module("OTR");
  c_otr_userstate = rb_define_class_under(m_otr, "UserState", rb_cObject);
  rb_define_singleton_method(m_otr, "init", method_otr_init, 0);
  rb_define_singleton_method(m_otr, "version", method_otr_version, 0);
  rb_define_method(c_otr_userstate, "initialize", method_userstate_initialize, 4);
  rb_define_method(c_otr_userstate, "read_privkey", method_userstate_read_privkey, 0);
  rb_define_method(c_otr_userstate, "generate_privkey", method_userstate_generate_privkey, 0);
  rb_define_method(c_otr_userstate, "read_fingerprints", method_userstate_read_fingerprints, 0);
  rb_define_method(c_otr_userstate, "write_fingerprints", method_userstate_write_fingerprints, 0);
  rb_define_method(c_otr_userstate, "sending", method_userstate_sending, 2);
  rb_define_method(c_otr_userstate, "receiving", method_userstate_receiving, 2);
}

