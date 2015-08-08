VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac stdio.vala --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H STDIO.h --library=STDIO -X -shared -X -fPIC -o ./lib/stdio.so
	vrbjs -d ./lib/stdio.so > ./lib/stdio.rb
	vrbjs -c ./lib/stdio.rb
	vrbjs -c ./lib/stdio/stdout.rb
	vrbjs -c ./lib/stdio/stderr.rb			
	vrbjs -c ./lib/stdio/stdin.rb			

clean:
	rm ./lib/stdio.rb
	rm ./lib/stdio.rb.js
	rm ./lib/stdio.so
	rm ./STDIO.vapi
	rm ./STDIO.h
	rm ./lib/stdio/*.rb.js

install:
	cp ./lib/stdio.so $(VRBJS_LIB_DIR)/
	cp ./lib/stdio.rb $(VRBJS_LIB_DIR)/
	cp ./lib/stdio.rb.js $(VRBJS_LIB_DIR)/	
	cp -rf ./lib/stdio/ $(VRBJS_LIB_DIR)/stdio/		
	cp STDIO.vapi $(VRBJS_LIB_DIR)/vapi/
	cp STDIO.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/stdio.so
	rm $(VRBJS_LIB_DIR)/stdio.rb
	rm $(VRBJS_LIB_DIR)/stdio.rb.js	
	rm -rf $(VRBJS_LIB_DIR)/stdio	
	rm $(VRBJS_LIB_DIR)/vapi/STDIO.vapi
	rm $(VRBJS_LIB_DIR)/include/STDIO.h
