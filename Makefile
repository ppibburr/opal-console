JSUTILS_LIB_DIR ?= /usr/lib/jsutils/0.1.0

all:
	make pkg
	make tool
	tools/dump ext/so_dump/so_dump > lib/so_dump.rb
	tools/dump vrb_js > lib/vrbjs.rb
	tools/dump bridge > lib/jsutils.rb
	tools/compile lib/vrbjs.rb > lib/vrbjs.rb.js
	tools/compile lib/jsutils.rb > lib/jsutils.rb.js
	tools/compile lib/so_dump.rb > lib/so_dump.rb.js
	
tool:
	cd ext/so_dump && make
	cd tools && valac dump.vala --pkg jsutils-0.1 --vapidir=/usr/lib/jsutils/0.1.0/vapi
	cd tools && valac compile.vala --pkg vrbjs --pkg jsutils-0.1 --vapidir=../ --vapidir=/usr/lib/jsutils/0.1.0/vapi -X /home/ppibburr/git/vrbjs/vrb_js.so -X -I../

pkg:
	valac src/lib/*vala --pkg jsutils-0.1 --vapidir=/usr/lib/jsutils/0.1.0/vapi -o vrb_js.so --library=vrbjs -H vrbjs.h -X -shared -X -fPIC
	
exec:
	valac src/bin/*vala --pkg vrbjs --pkg jsutils-0.1 --vapidir=/usr/lib/jsutils/0.1.0/vapi -o vrbjs -X -I$(JSUTILS_LIB_DIR)/include/ -X $(JSUTILS_LIB_DIR)/vrb_js.so

clean:
	cd ext/so_dump && make clean
	rm *.so
	rm *.h
	rm *.vapi
	rm vrbjs
	rm -rf tools/dump
	rm -rf tools/compile
	
install:
	sudo mkdir -p $(JSUTILS_LIB_DIR)/vrbjs/include
	sudo mkdir -p $(JSUTILS_LIB_DIR)/vrbjs/vapi
	sudo cp -rf lib/* $(JSUTILS_LIB_DIR)/vrbjs/
	sudo cp ext/*/*.so $(JSUTILS_LIB_DIR)/vrbjs/
	sudo cp vrb_js.so $(JSUTILS_LIB_DIR)/
	sudo cp vrbjs.vapi $(JSUTILS_LIB_DIR)/vapi/
	sudo cp ext/*/*.vapi $(JSUTILS_LIB_DIR)/vrbjs/vapi/	
	sudo cp vrbjs.h $(JSUTILS_LIB_DIR)/include/
	sudo cp ext/*/*.h $(JSUTILS_LIB_DIR)/vrbjs/include/
	make exec
	sudo cp vrbjs /usr/bin/
