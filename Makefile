all:
	valac src/lib/*.vala --vapidir=vapi/javascriptcore --pkg jscore -X -I/usr/include/webkitgtk-1.0 -X -ljavascriptcoregtk-3.0 --library=Opal --vapi=ovala.vapi -H ovala.h -X -fPIC -X -shared -o libovala.so && valac src/bin/ovala.vala --pkg ovala --vapidir=./ --pkg jscore --vapidir=./vapi/javascriptcore -X -I/usr/include/webkitgtk-3.0 -X -ljavascriptcoregtk-3.0

clean:
	rm -rf libovala.so ovala.vapi ovala.h ovala

install:
	cp -f libovala.so /usr/lib/
	cp -f ovala.vapi /usr/share/vala/vapi/
	cp -f ovala.h /usr/include/
	cp -f ovala.pc /usr/lib/pkgconfig/
	cp -f ovala /usr/bin/	
	
uninstall:
	rm -rf /usr/lib/libovala.so
	rm -rf /usr/share/vala/ovala.vapi
	rm -rf /usr/include/ovala.h    
	rm -rf /usr/lib/pkgconfig/ovala.pc
	rm -rf /usr/bin/ovala	
