all:
	valac src/lib/*.vala src/lib/*/*.vala --pkg gio-2.0 --pkg gee-1.0 --vapidir=vapi/libffi --pkg libffi --vapidir=vapi/javascriptcore --pkg jscore -X -I/usr/include/webkitgtk-1.0 -X -ljavascriptcoregtk-3.0 --library=Opal --pkg gee-1.0 --vapi=opala-0.1.vapi -H opala-0.1.h -X -fPIC -X -shared -o libopala.so && valac src/bin/opala.vala src/lib/*.vala src/lib/*/*.vala --vapidir=./ --vapidir=vapi/libffi --pkg libffi --pkg jscore --vapidir=./vapi/javascriptcore --vapidir=vapi/webkitgtk-3.0 --pkg webkitgtk-3.0 --pkg gtk+-3.0  --pkg gee-1.0 --pkg Soup-2.4 -X -I/usr/include/webkitgtk-3.0 -X -ljavascriptcoregtk-3.0 -X -I./ -X -ldl -X -lffi

clean:
	rm -rf libopala.so opala-0.1.vapi opala-0.1.h opala

install:
	cp -f libopala.so /usr/lib/
	cp -f opala-0.1.vapi /usr/share/vala/vapi/
	cp -f opala-0.1.h /usr/include/
	cp -f opala.pc /usr/lib/pkgconfig/
	cp -f opala /usr/bin/	
	
uninstall:
	rm -rf /usr/lib/libopala.so
	rm -rf /usr/share/vala/opala-0.1.vapi
	rm -rf /usr/include/opala-0.1.h    
	rm -rf /usr/lib/pkgconfig/opala.pc
	rm -rf /usr/bin/opala	
