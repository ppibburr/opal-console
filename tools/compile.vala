using VRbJS;
void main(string[] argv) {
	JSUtils.debug_state = true;
	var c = new Context();
	c.load_so("bridge");
	c.load_so("/home/ppibburr/git/vrbjs/vrb_js.so");
	string code;
	FileUtils.get_contents(argv[1], out code, null);
	stdout.puts(c.compile(code));
}
