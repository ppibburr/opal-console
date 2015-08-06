VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac ffi.vala --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H FFI.h --library=FFI -X -shared -X -fPIC -o ffi.so --vapidir=../../../../vapi/libffi --pkg ffi --pkg gee-1.0
	vrbjs -d ./ffi.so > ./ffi.rb
	vrbjs -c ./ffi.rb

clean:
	rm ./ffi.rb
	rm ./ffi.rb.js
	rm ./ffi.so
	rm ./FFI.vapi
	rm ./FFI.h

install:
	cp ./ffi.so $(VRBJS_LIB_DIR)/
	cp ./ffi.rb $(VRBJS_LIB_DIR)/
	cp ./ffi.rb.js $(VRBJS_LIB_DIR)/	
	cp ../../../../vapi/libffi/ffi.vapi $(VRBJS_LIB_DIR)/vapi/	
	cp FFI.vapi $(VRBJS_LIB_DIR)/vapi/
	cp FFI.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/ffi.so
	rm $(VRBJS_LIB_DIR)/ffi.rb
	rm $(VRBJS_LIB_DIR)/ffi.rb.js	
	rm $(VRBJS_LIB_DIR)/vapi/ffi.vapi
	rm $(VRBJS_LIB_DIR)/vapi/FFI.vapi
	rm $(VRBJS_LIB_DIR)/include/FFI.h
