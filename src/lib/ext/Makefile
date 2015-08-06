VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:

ffi:
	valac ffi.vala --pkg vrbjs-0.1 --vapidir=../../../vapi/javascriptcore --library=FFI -X -shared -X -fPIC -o ffi.so --vapidir=../../../vapi/libffi --pkg ffi --pkg gee-1.0
	vrbjs -d ./ffi.so > ./ffi.rb
	vrbjs -c ./ffi.rb

clean:
	rm ./ffi.rb
	rm ./ffi.rb.js
	rm ./ffi.so
	rm ./FFI.vapi

install:
	cp ./ffi.so $(VRBJS_LIB_DIR)/
	cp ./ffi.rb $(VRBJS_LIB_DIR)/
	cp ./ffi.rb.js $(VRBJS_LIB_DIR)/	
