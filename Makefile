all:
	valac src/lib/*.vala --vapidir=vapi/javascriptcore --pkg jscore -X -I/usr/include/webkitgtk-1.0 -X -ljavascriptcoregtk-3.0 --library=Opal --vapi=opala-0.1.vapi -H opala-0.1.h -X -fPIC -X -shared -o libopala.so && valac src/bin/opala.vala src/lib/*.vala --vapidir=./ --pkg jscore --vapidir=./vapi/javascriptcore -X -I/usr/include/webkitgtk-3.0 -X -ljavascriptcoregtk-3.0 -X -I./ 

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
