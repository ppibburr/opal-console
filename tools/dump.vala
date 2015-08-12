using JSUtils;
void main(string[] argv) {
	var c = new Context();
	
	c.load_so("bridge");
	c.load_so("/home/ppibburr/git/vrbjs/vrb_js.so");
	c.load_so("/home/ppibburr/git/vrbjs/ext/so_dump/so_dump.so");
	c.get_environment().add_search_path("/home/ppibburr/git/vrbjs/ext");
	stdout.puts((string)c.exec(@"VRbJS.SoDump.dump(\"$(argv[1])\");"));
}
