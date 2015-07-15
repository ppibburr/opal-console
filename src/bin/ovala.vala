void main(string[] argv) {
	Opal.Runtime opal = null;
	
	 // transpile <foo>.rb to <foo>.rb.js
	 if (argv[1] == "-c") {
		opal = new Opal.Runtime(true);
		var code = "";
		FileUtils.get_contents(argv[2], out code, null);
		var result = opal.context.exec("""Opal.compile("%s");""".printf(code.escape(null))).to_string();
		FileUtils.set_contents(argv[2]+".js", result);
	
	// Execute a file
	//
	// if extension is '.js' simply execute the file
	// if              '.rb' load 'opal-parser' then execute the file
	} else if (argv[1] != "-e") {
		var n = argv[1].split(".");
		var ext = n[n.length-1];
		switch (ext) {
		// Load 'opal-parser' before execution
		case "rb":
		    opal = new Opal.Runtime(true, argv[2:argv.length]);
			opal.load(@"$(argv[1])");
			break;
		
		// simply execute	
		case "js":
		    opal = new Opal.Runtime(false, argv[2:argv.length]);
		    var code = "";
		    FileUtils.get_contents(argv[1], out code, null);
		    opal.context.exec(code);
		    break;
		}

	// Execute inline script	
	} else if (argv[1] == "-e") {
		opal = new Opal.Runtime(true);
		opal.exec(argv[2]);
	}
}
