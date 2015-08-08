VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac env.vala --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H ENV.h --library=ENV -X -shared -X -fPIC -o ./lib/env.so
	vrbjs -d ./lib/env.so > ./lib/env.rb
	echo "\n\nVRbJS.require \"env/env\"" >> ./lib/env.rb	
	vrbjs -c ./lib/env.rb
	vrbjs -c ./lib/env/env.rb

clean:
	rm ./lib/env.rb
	rm ./lib/env.rb.js
	rm ./lib/env.so
	rm ./ENV.vapi
	rm ./ENV.h
	rm ./lib/env/*.rb.js

install:
	cp ./lib/env.so $(VRBJS_LIB_DIR)/
	cp ./lib/env.rb $(VRBJS_LIB_DIR)/
	cp ./lib/env.rb.js $(VRBJS_LIB_DIR)/	
	cp -rf ./lib/env/ $(VRBJS_LIB_DIR)/env/		
	cp ENV.vapi $(VRBJS_LIB_DIR)/vapi/
	cp ENV.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/env.so
	rm $(VRBJS_LIB_DIR)/env.rb
	rm $(VRBJS_LIB_DIR)/env.rb.js	
	rm -rf $(VRBJS_LIB_DIR)/env	
	rm $(VRBJS_LIB_DIR)/vapi/ENV.vapi
	rm $(VRBJS_LIB_DIR)/include/ENV.h
