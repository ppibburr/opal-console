VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac ffi.vala --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H FFI.h --library=FFI -X -shared -X -fPIC -o ffi.so --vapidir=../../../../vapi/libffi --pkg ffi --pkg gee-1.0
	vrbjs -d ./ffi.so > ./ffi.rb
	vrbjs -c ./ffi.rb
	vrbjs -c ./lib/gtk.rb
	vrbjs -c ./lib/gobject.rb	
	vrbjs -c ./lib/vrbjs/load_status.rb	
	vrbjs -c ./lib/vrbjs/app.rb						

clean:
	rm ./ffi.rb
	rm ./ffi.rb.js
	rm ./ffi.so
	rm ./FFI.vapi
	rm ./FFI.h
	rm ./lib/*.rb.js
	rm ./lib/vrbjs/*.rb.js

install:
	cp ./ffi.so $(VRBJS_LIB_DIR)/
	cp ./ffi.rb $(VRBJS_LIB_DIR)/
	cp ./ffi.rb.js $(VRBJS_LIB_DIR)/	
	cp -rf ./lib/*.rb $(VRBJS_LIB_DIR)/	
	cp -rf ./lib/vrbjs/*.rb $(VRBJS_LIB_DIR)/vrbjs/		
	cp ../../../../vapi/libffi/ffi.vapi $(VRBJS_LIB_DIR)/vapi/	
	cp FFI.vapi $(VRBJS_LIB_DIR)/vapi/
	cp FFI.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/ffi.so
	rm $(VRBJS_LIB_DIR)/ffi.rb
	rm $(VRBJS_LIB_DIR)/ffi.rb.js
	rm $(VRBJS_LIB_DIR)/gobject.rb	
	rm $(VRBJS_LIB_DIR)/gtk.rb	
	rm $(VRBJS_LIB_DIR)/gobject.rb.js	
	rm $(VRBJS_LIB_DIR)/gtk.rb.js			
	rm $(VRBJS_LIB_DIR)/vrbjs/load_status.rb
	rm $(VRBJS_LIB_DIR)/vrbjs/app.rb	
	rm $(VRBJS_LIB_DIR)/vrbjs/load_status.rb.js
	rm $(VRBJS_LIB_DIR)/vrbjs/app.rb.js		
	rm $(VRBJS_LIB_DIR)/vapi/ffi.vapi
	rm $(VRBJS_LIB_DIR)/vapi/FFI.vapi
	rm $(VRBJS_LIB_DIR)/include/FFI.h
