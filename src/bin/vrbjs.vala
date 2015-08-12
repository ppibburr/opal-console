using VRbJS;
void main(string[] argv) {
	//JSUtils.debug_state = true;
	var c = new Context();
	
	c.rb_require("js");		
	c.rb_require("vrbjs");
	c.rb_require("jsutils");	
	
	JSCore.Value e = null;
	
	if ("-e" in argv && argv.length > 2 && argv[argv.length-1] != "-e") {
		c.eval(argv[argv.length-1], out e);
	
	} else if (argv.length == 2) {
		c.load(argv[1]);
	}
	
	if (e != null) {
		stderr.puts(JSUtils.object_to_string(c, (JSCore.Object)e));
		stderr.puts((string)((JSUtils.Object)e).get_prop(c, "stack"));
	}
}
