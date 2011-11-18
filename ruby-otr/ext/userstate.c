#include "ruby-otr.h"

#define ivar_get(name)  RSTRING_PTR(rb_ivar_get(self, rb_intern(name)))
extern OtrlMessageAppOps uiops;

#define ivar_to_cstr(name)                                              \
  char* name;                                                           \
  VALUE ivar ## _ ## name =                                             \
    rb_ivar_get(self, rb_intern("@" __STRING(name)));                   \
  name = StringValuePtr(ivar ## _ ## name);

VALUE method_userstate_initialize(VALUE self, VALUE account, VALUE protocol, VALUE key_file, VALUE fingerprints) {
  const OtrlUserState userstate = otrl_userstate_create();
  rb_ivar_set(self, rb_intern("@userstate"), LONG2FIX(userstate));
  rb_ivar_set(self, rb_intern("@account"), account);
  rb_ivar_set(self, rb_intern("@protocol"), protocol);
  rb_ivar_set(self, rb_intern("@key_file"), key_file);
  rb_ivar_set(self, rb_intern("@fingerprint_file"), fingerprints);
  method_userstate_read_fingerprints(self);
  
  return self;
}

VALUE method_userstate_read_privkey(VALUE self) {
  //char* key_file = ivar_get(self, "@key_file");
  ivar_to_cstr(key_file);
  gcry_error_t err = otrl_privkey_read(get_userstate(self), key_file);
  if(err)
    //rb_raise(rb_eRuntimeError, gcry_strerror(err));
    return Qfalse;
  return Qtrue;
}


VALUE method_userstate_generate_privkey(VALUE self) {
  ivar_to_cstr(key_file);
  ivar_to_cstr(account);
  ivar_to_cstr(protocol);
  
  /* char *key_file = ivar_get("@key_file"); */
  /* char *account = ivar_get("@account"); */
  /* char *protocol = ivar_get("@protocol"); */

  gcry_error_t err = otrl_privkey_generate(get_userstate(self), key_file, account, protocol);
  if(err) { return Qfalse; } else { return Qtrue; }
}

VALUE method_userstate_read_fingerprints(VALUE self) {
  char *fingerprints = ivar_get("@fingerprint_file");
  gcry_error_t err = otrl_privkey_read_fingerprints(get_userstate(self), fingerprints, NULL, NULL);
  if(err) { return Qfalse; } else { return Qtrue; } // TODO
  // didn't we find out that you can't check aginst gcry_error_t with if but a macro instead(find name of this macro)
}

VALUE method_userstate_write_fingerprints(VALUE self) {
  char *fingerprints = ivar_get("@fingerprint_file");
  gcry_error_t err = otrl_privkey_write_fingerprints(get_userstate(self), fingerprints);
  if(err) { return Qfalse; } else { return Qtrue; }
}

VALUE method_userstate_sending(VALUE self, VALUE r_to, VALUE r_text) {
  char *account = ivar_get("@account");
  char *protocol = ivar_get("@protocol");
  char *to = StringValuePtr(r_to);
  char *message = StringValuePtr(r_text);
  gcry_error_t err;
  char *newmessage = NULL;

  err = otrl_message_sending(get_userstate(self), &uiops, (void *)self, account, protocol, to, message, 0, &newmessage, NULL, NULL);
  
  if (!err == GPG_ERR_NO_ERROR)
    rb_raise(rb_eRuntimeError, "%s", gcry_strerror(err));
  //err otrl_message_fragment_and_send(&uiops, (void*) opdata,
//				     ConnContext *context, 
//				     newmessage,
//				     OtrlFragmentPolicy fragPolicy,
//				     char **returnFragment);

  if (!err == GPG_ERR_NO_ERROR)
    rb_raise(rb_eRuntimeError, "%s", gcry_strerror(err));  
  else
    return rb_str_new_cstr(newmessage);
}

VALUE method_userstate_receiving(VALUE self, VALUE r_from, VALUE r_text) {

  char *account = ivar_get("@account");
  char *protocol = ivar_get("@protocol");
  char *from = StringValuePtr(r_from);
  char *message = StringValuePtr(r_text);

  int ignore_message;
  char *newmessage = NULL;

  ignore_message = otrl_message_receiving(get_userstate(self), &uiops, (void *)self, account, protocol, from, message, &newmessage, 0, NULL, NULL);

  if(ignore_message) {
    return Qnil;
  } else {
    if(newmessage) {
      return rb_str_new_cstr(newmessage);
    } else {
      return rb_str_new_cstr(message);
    }
  }
}

OtrlUserState get_userstate(VALUE obj) {
  OtrlUserState userstate = (OtrlUserState) FIX2LONG(rb_ivar_get(obj, rb_intern("@userstate")));
  return userstate;
}


