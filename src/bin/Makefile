define EXTRAS
endef

ifdef WEBKIT
	EXTRAS += -D WEBKIT --vapidir=../../vapi/webkitgtk-3.0 --pkg webkitgtk-3.0
endif

all:
	valac vrbjs.vala --vapidir=../../vapi/javascriptcore --pkg vrbjs-0.1 --pkg gee-1.0

clean:
	rm -rf vrbjs

install:
	cp -f vrbjs /usr/bin/
	
uninstall:
	rm -rf /usr/bin/vrbjs
