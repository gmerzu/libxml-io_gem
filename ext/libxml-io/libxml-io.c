#include "ruby.h"

#include <libxml/parser.h>
#include <libxml/xmlreader.h>

static VALUE LibXMLIO = Qnil;

typedef struct libxml_io_doc_context {
	char *buffer;
	char *bpos;
	int remaining;
} libxml_io_doc_context;

typedef struct libxml_io_handler {
	VALUE class;
	struct libxml_io_handler *next_handler;
} libxml_io_handler;

static libxml_io_handler *first_handler = 0;

static int libxml_io_registered = 0;

static int libxml_io_match(char const *filename)
{
	libxml_io_handler *handler;
	VALUE res;

	handler = first_handler;
	while (handler) {
		res = rb_funcall(handler->class, rb_intern("match"), 1, rb_str_new2(filename));
		if (!(RUBY_Qfalse == res || RUBY_Qnil == res || RUBY_Qundef == res)) {
			return 1;
		}
		handler = handler->next_handler;
	}
	return 0;
}

static void* libxml_io_open(char const *filename)
{
	libxml_io_handler *handler;
	VALUE res;

	handler = first_handler;
	while (handler) {
		res = rb_funcall(handler->class, rb_intern("query"), 1, rb_str_new2(filename));
		if (!(RUBY_Qfalse == res || RUBY_Qnil == res || RUBY_Qundef == res || !strlen(StringValuePtr(res)))) {
			libxml_io_doc_context *libxml_io_doc;
			libxml_io_doc = (libxml_io_doc_context*)malloc(sizeof(libxml_io_doc_context));
			libxml_io_doc->buffer = strdup(StringValuePtr(res));
			libxml_io_doc->bpos = libxml_io_doc->buffer;
			libxml_io_doc->remaining = (int)strlen(libxml_io_doc->buffer);
			return libxml_io_doc;
		}
		handler = handler->next_handler;
	}

	return 0;
}

static int libxml_io_read(void *context, char *buffer, int len)
{
	int ret_len;
	libxml_io_doc_context *libxml_io_doc = (libxml_io_doc_context*)context;

	if (len >= libxml_io_doc->remaining) {
		ret_len = libxml_io_doc->remaining;
	} else {
		ret_len = len;
	}
	strncpy(buffer, libxml_io_doc->bpos, ret_len);
	libxml_io_doc->bpos += ret_len;
	libxml_io_doc->remaining -= ret_len;

	return ret_len;
}

static int libxml_io_close(void *context)
{
	ruby_xfree(((libxml_io_doc_context*)context)->buffer);
	ruby_xfree(context);
	return 1;
}

static VALUE libxml_io_register_input_callbacks()
{
	if (libxml_io_registered) {
		return Qfalse;
	}
	xmlRegisterInputCallbacks(libxml_io_match, libxml_io_open, libxml_io_read, libxml_io_close);
	libxml_io_registered = 1;
	return Qtrue;
}

static VALUE libxml_io_pop_input_callbacks()
{
	if (!libxml_io_registered) {
		return Qfalse;
	}
	xmlPopInputCallbacks();
	libxml_io_registered = 0;
	return Qtrue;
}

static VALUE libxml_io_add_handler(VALUE self, VALUE class)
{
	libxml_io_handler *handler;

	handler = (libxml_io_handler*)malloc(sizeof(libxml_io_handler));
	handler->next_handler = 0;
	handler->class = class;

	if (!first_handler) {
		first_handler = handler;
	} else {
		libxml_io_handler *pos;
		pos = first_handler;
		while (pos->next_handler) {
			pos = pos->next_handler;
		}
		pos->next_handler = handler;
	}

	return Qtrue;
}

static VALUE libxml_io_remove_handler(VALUE self, VALUE class)
{
	libxml_io_handler *save_handler, *handler;

	if (!first_handler) {
		return Qfalse;
	}

	if (class == first_handler->class) {
		save_handler = first_handler->next_handler;
		ruby_xfree(first_handler);
		first_handler = save_handler;
		return Qtrue;
	}

	handler = first_handler;
	while (handler->next_handler) {
		if (class == handler->next_handler->class) {
			save_handler = handler->next_handler->next_handler;
			ruby_xfree(handler->next_handler);
			handler->next_handler = save_handler;
			return Qtrue;
		}
		handler = handler->next_handler;
	}
	return Qfalse;
}

static VALUE libxml_io_clear_handlers(VALUE self)
{
	libxml_io_handler *save_handler, *handler;

	handler = first_handler;
	while (handler) {
		save_handler = handler;
		handler = handler->next_handler;
		ruby_xfree(save_handler);
	}
	first_handler = 0;
	return Qtrue;
}

static void libxml_io_init_input_callbacks(void)
{
	VALUE cInputCallbacks = rb_define_class_under(LibXMLIO, "InputCallbacks", rb_cObject);

	rb_define_singleton_method(cInputCallbacks, "register",
			libxml_io_register_input_callbacks, 0);
	rb_define_singleton_method(cInputCallbacks, "pop",
			libxml_io_pop_input_callbacks, 0);
	rb_define_singleton_method(cInputCallbacks, "add_handler",
			libxml_io_add_handler, 1);
	rb_define_singleton_method(cInputCallbacks, "remove_handler",
			libxml_io_remove_handler, 1);
	rb_define_singleton_method(cInputCallbacks, "clear_handlers",
			libxml_io_clear_handlers, 0);
}

void Init_libxml_io()
{
	LibXMLIO = rb_define_module_under(rb_define_module("LibXML"), "IO");
	libxml_io_init_input_callbacks();
}
