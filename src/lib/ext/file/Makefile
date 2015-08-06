VRBJS_LIB_DIR ?= /usr/lib/vrbjs/0.1.0

all:
	valac file.vala --pkg vrbjs-0.1 --vapidir=../../../../vapi/javascriptcore -H file.h --library=File -X -shared -X -fPIC -o file.so --pkg gee-1.0 --pkg gio-2.0
	vrbjs -d ./file.so > ./file.rb
	echo "\n\nclass VRbJS::File\n  def self.open(path, mode=\"r\")\n    self.new(path)\n  end\n\nend" >> file.rb
	vrbjs -c ./file.rb

clean:
	rm ./file.rb
	rm ./file.rb.js
	rm ./file.so
	rm ./File.vapi
	rm ./file.h

install:
	cp ./file.so $(VRBJS_LIB_DIR)/
	cp ./file.rb $(VRBJS_LIB_DIR)/
	cp ./file.rb.js $(VRBJS_LIB_DIR)/	
	cp File.vapi $(VRBJS_LIB_DIR)/vapi/
	cp file.h $(VRBJS_LIB_DIR)/include/

uninstall:
	rm $(VRBJS_LIB_DIR)/file.so
	rm $(VRBJS_LIB_DIR)/file.rb
	rm $(VRBJS_LIB_DIR)/file.rb.js	
	rm $(VRBJS_LIB_DIR)/vapi/File.vapi
	rm $(VRBJS_LIB_DIR)/include/file.h
