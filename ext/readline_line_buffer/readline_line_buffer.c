/* readline.c -- GNU Readline module
   Copyright (C) 1997-2001  Shugo Maeda */
/* body of line_buffer() from irb enhancements at http://www.creo.hu/~csaba/ruby/ */
 
#ifdef HAVE_READLINE_READLINE_H
#include "ruby.h"
#include <errno.h>
#include <stdio.h>
#include <readline/readline.h>

static VALUE line_buffer(VALUE self)
{
    rb_secure(4);
    if (rl_line_buffer == NULL)
      return Qnil;
    return rb_tainted_str_new2(rl_line_buffer);
}

void Init_readline_line_buffer() {
  VALUE c = rb_cObject;
  c = rb_const_get(c, rb_intern("Readline"));
  rb_define_singleton_method(c, "line_buffer", (VALUE(*)(ANYARGS))line_buffer, -1);
}
#endif
