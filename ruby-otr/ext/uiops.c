#include "ruby-otr.h"

//static OtrlPolicy (*ui_policy_cb)(ConnContext *) = NULL;

static OtrlPolicy policy_cb(void *opdata, ConnContext *context) {
  VALUE res = rb_funcall((VALUE)opdata, rb_intern("policy_cb"), 1, Qnil);

  if(TYPE(res) == T_FIXNUM){
    return (OtrlPolicy)FIX2INT(res);
  }
  else {
    printf("using OTRL_PLOICY_DEFAULT");
    return OTRL_POLICY_DEFAULT; 
  }
}


static void create_privkey_cb(void *opdata, const char *accountname, const char *protocol) {
  VALUE r_accountname = rb_str_new_cstr(accountname);
  VALUE r_protocol = rb_str_new_cstr(protocol);
  rb_funcall((VALUE)opdata, rb_intern("create_privkey_cb"), 2, r_accountname, r_protocol);
}


static int is_logged_in_cb(void *opdata, const char *accountname, const char *protocol, const char *recipient) {
  VALUE r_accountname = rb_str_new_cstr(accountname);
  VALUE r_protocol = rb_str_new_cstr(protocol);
  VALUE r_recipient = rb_str_new_cstr(recipient);

  VALUE res = rb_funcall((VALUE)opdata, rb_intern("is_logged_in_cb"), 3, r_accountname, r_protocol, r_recipient);

  if(res == Qtrue)
    return 1;
  else if(res == Qfalse)
    return 0;
  else
    return -1;
}


static void inject_message_cb(void *opdata, const char *accountname, const char *protocol, const char *recipient, const char *message) {
  VALUE r_recipient = rb_str_new_cstr(recipient);
  VALUE r_message = rb_str_new_cstr(message);
  rb_funcall((VALUE)opdata, rb_intern("inject_message_cb"), 2, r_recipient, r_message);
}

VALUE otrl_notify_level_level_to_symbol(OtrlNotifyLevel level){
  const char *ret;
  switch(level) {
  case OTRL_NOTIFY_ERROR: 
    ret = "error";
    break;
  case OTRL_NOTIFY_WARNING:
    ret = "warning";
    break;
  case OTRL_NOTIFY_INFO:
    ret = "info";
    break;
  default:
    ret = "undefined";
    break;
  }
  return rb_funcall(rb_str_new_cstr(ret),rb_intern("to_sym"), 0);
}

static void notify_cb(void *opdata, OtrlNotifyLevel level, const char *accountname, const char *protocol, const char *username, const char *title, const char *primary, const char *secondary) {
  VALUE r_level = otrl_notify_level_level_to_symbol(level);
  VALUE r_username = rb_str_new_cstr(username);
  VALUE r_title = rb_str_new_cstr(title);
  VALUE r_primary = rb_str_new_cstr(primary);
  VALUE r_secondary = rb_str_new_cstr(secondary);

  rb_funcall((VALUE)opdata, rb_intern("notify_cb"), 5, r_level, r_username, r_title, r_primary, r_secondary);
}


static int display_otr_message_cb(void *opdata, const char *accountname, const char *protocol, const char *username, const char *message) {
  VALUE r_accountname = rb_str_new_cstr(accountname);
  VALUE r_protocol = rb_str_new_cstr(protocol);
  VALUE r_username = rb_str_new_cstr(username);
  VALUE r_message = rb_str_new_cstr(message);

  VALUE res = rb_funcall((VALUE)opdata, rb_intern("display_otr_message_cb"), 4, r_accountname, r_protocol, r_username, r_message);

  if(res == Qtrue)
    return 0;
  else
    return -1;
}


static void update_context_list_cb(void *opdata) {
  //rb_funcall((VALUE)opdata, rb_intern("update_context_list_cb"), 0);
}


static const char *protocol_name_cb(void *opdata, const char *protocol) {
  VALUE r_protocol = rb_str_new_cstr(protocol);
  
  VALUE res = rb_funcall((VALUE)opdata, rb_intern("protocol_name_cb"), 1, r_protocol);

  if(res)
    return RSTRING_PTR(res);
  else
    return protocol;
}


static void protocol_name_free_cb(void *opdata, const char *protocol_name) {
}


static void new_fingerprint_cb(void *opdata, OtrlUserState us, const char *accountname, const char *protocol, const char *username, unsigned char fingerprint[20]) {
  VALUE r_accountname = rb_str_new_cstr(accountname);
  VALUE r_protocol = rb_str_new_cstr(protocol);
  VALUE r_username = rb_str_new_cstr(username);
  VALUE r_fingerprint = rb_str_new_cstr((char *)fingerprint); // TODO this might be no good idea and maybe wrong fingerprint is 20 chars long and of numbers this assumes \0 terminated string I think

  rb_funcall((VALUE)opdata, rb_intern("new_fingerprint_cb"), 4, r_accountname, r_protocol, r_username, r_fingerprint);
}


static void write_fingerprints_cb(void *opdata) {
  VALUE  sucess = method_userstate_write_fingerprints((VALUE)opdata);
  rb_funcall((VALUE)opdata, rb_intern("write_fingerprints_cb"), 1, sucess);
}


static void gone_secure_cb(void *opdata, ConnContext *context) { 
  rb_ivar_set((VALUE)opdata, rb_intern("@secure"), Qtrue);
  /*printf("\n ---------- ivar set \n");
  VALUE cConnContext = rb_define_class("ConnContext", rb_cObject);
  printf("\n ---------- defined class structur \n") ;
  VALUE r_ConnContext = Data_Wrap_Struct(cConnContext,
					 1, -1,
					 context);
  printf("\n ---------- wraped structur \n");
  rb_funcall((VALUE)opdata, rb_intern("secure_cb"), 1, r_ConnContext);
//  VALUE r_context = Qnil;
//  VALUE r_protocol_version = INT2FIX(protocol_version);
//  rb_funcall((VALUE)opdata, rb_intern("gone_secure_cb"), 2, r_context, r_protocol_version);
*/}



static void gone_insecure_cb(void *opdata, ConnContext *context) {
  rb_ivar_set((VALUE)opdata, rb_intern("@secure"), Qfalse);
  //VALUE r_ConnContext = Data_Make_Struct(opdata, ConnContext, 1, -1, context);
  //rb_funcall((VALUE)opdata, rb_intern("secure_cb"), 1, r_ConnContext);
}


static void still_secure_cb(void *opdata, ConnContext *context, int is_reply) {
  rb_ivar_set((VALUE)opdata, rb_intern("@secure"), Qtrue);
  //  VALUE r_ConnContext = Data_Make_Struct(opdata, ConnContext, 1, -1, context);
  //rb_funcall((VALUE)opdata, rb_intern("secure_cb"), 1, r_ConnContext);
}


static void log_message_cb(void *opdata, const char *message) {
  VALUE r_message = rb_str_new_cstr(message);
  rb_funcall((VALUE)opdata, rb_intern("log_message_cb"), 1, r_message);
}


OtrlMessageAppOps uiops = {
  policy_cb,
  create_privkey_cb,
  is_logged_in_cb,
  inject_message_cb,
  notify_cb,
  display_otr_message_cb,
  update_context_list_cb,
  protocol_name_cb,
  protocol_name_free_cb,
  new_fingerprint_cb,
  write_fingerprints_cb,
  gone_secure_cb,
  gone_insecure_cb,
  still_secure_cb,
  log_message_cb
};
