all:
	valac src/lib/*.vala  --pkg gee-1.0 --vapidir=vapi/javascriptcore --pkg javascriptcoregtk-3.0 -X -ldl --library=VRbJS --pkg gee-1.0 --vapi=vrbjs-0.1.vapi -H vrbjs.h -X -fPIC -X -shared -o libvrbjs-0.1.so

clean:
	rm -rf libvrbjs-0.1.so vrbjs-0.1.vapi vrbjs.h

install:
	cp -f libvrbjs-0.1.so /usr/lib/
	cp -f vrbjs-0.1.vapi /usr/share/vala/vapi/
	cp -f vrbjs-0.1.deps /usr/share/vala/vapi/
	cp -f vrbjs.h /usr/include/
	cp -f vrbjs-0.1.pc /usr/lib/pkgconfig/
	
uninstall:
	rm -rf /usr/lib/libvrbjs-0.1.so
	rm -rf /usr/share/vala/vrbjs-0.1.vapi
	rm -rf /usr/share/vala/vrbjs-0.1.deps	
	rm -rf /usr/include/vrbjs.h    
	rm -rf /usr/lib/pkgconfig/vrbjs-0.1.pc	
