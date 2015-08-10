VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac spawn.vala --pkg gee-1.0 --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H SPAWN.h --library=SPAWN -X -shared -X -fPIC -o ./lib/spawn.so
	vrbjs -d ./lib/spawn.so > ./lib/spawn.rb
	echo "\n\nVRbJS.require \"spawn/spawn\"" >> ./lib/spawn.rb	
	vrbjs -c ./lib/spawn.rb
	vrbjs -c ./lib/spawn/spawn.rb

clean:
	rm ./lib/spawn.rb
	rm ./lib/spawn.rb.js
	rm ./lib/spawn.so
	rm ./SPAWN.vapi
	rm ./SPAWN.h
	rm ./lib/spawn/*.rb.js

install:
	cp ./lib/spawn.so $(VRBJS_LIB_DIR)/
	cp ./lib/spawn.rb $(VRBJS_LIB_DIR)/
	cp ./lib/spawn.rb.js $(VRBJS_LIB_DIR)/	
	cp -rf ./lib/spawn/ $(VRBJS_LIB_DIR)/spawn/		
	cp SPAWN.vapi $(VRBJS_LIB_DIR)/vapi/
	cp SPAWN.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/spawn.so
	rm $(VRBJS_LIB_DIR)/spawn.rb
	rm $(VRBJS_LIB_DIR)/spawn.rb.js	
	rm -rf $(VRBJS_LIB_DIR)/spawn	
	rm $(VRBJS_LIB_DIR)/vapi/SPAWN.vapi
	rm $(VRBJS_LIB_DIR)/include/SPAWN.h
