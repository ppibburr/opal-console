all:
	valac *.vala --pkg jsutils-0.1 --vapidir=/usr/lib/jsutils/0.1.0/vapi --library=so_dump -H sodump.h -X -shared -X -fPIC -o /home/ppibburr/git/vrbjs/ext/so_dump/so_dump.so

clean:
	rm *.so
	rm *.h
	rm *.vapi
