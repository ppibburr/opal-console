namespace VRbJS {
	using JSUtils;
	public class Runtime {
		private bool owns_context = false;
		private weak JSUtils.Context weak_context;
		private JSUtils.Context owned_context;				
		public Context context {
			get {
				if (owns_context) {
					return owned_context;
				}
				
				return weak_context;
			}
		}
		
		public string[] argv {get; set; default = new string[0];}
        public JSUtils.Binder? global_class {get; private set; default=null;}

		public Runtime(bool? parser=null, string[]? argv = null, JSUtils.Context? context = null) {
			if (parser == null) {
				parser = false;
			}
			
			this.argv = argv ?? new string[0];
            
            if (context == null) {
				this.owned_context = new JSUtils.Context();
				owns_context = true;
			} else {
				this.weak_context = context;
				owns_context = false;
			}
            
            //VRbJS.debug("RUNTIME: 001");

			init_opal(parser, argv);
			
			//VRbJS.debug("RUNTIME: 002");
		}
		
		public class Console : JSUtils.Binder {
			public Console() {
				base("Console");

				bind("log", (self, args, c, out e) => {
					if (value_type(args[0]) != ValueType.OBJECT) {
						print("%s\n", v2str(args[0]));
					} else {
						print("%s\n", object_to_string(c, (JSCore.Object)args[0]));
					}
					
					return null;
				});
				
				close();
			}
		}
		
		
		// Provide a simple 'console.log()'
		protected void init_console(owned JSUtils.Binder? console_class = null) {
			  if (console_class == null) {
				  console_class = (Binder?)new Console();
			  }
			  
			  var console = new JSCore.Object(this.context, console_class.js_class, null);
			  var g       = context.get_global_object();
			  
			  g.set_property(this.context, new JSCore.String.with_utf8_c_string("console"), console, JSCore.PropertyAttribute.ReadOnly, null);
			  
			  var name = new JSCore.String.with_utf8_c_string("binder");
			  JSCore.Value binder;
			  JSUtils.Value.string(this.context, Type.from_instance(console_class).name(), out binder);
			  
			  console.set_property(this.context, name, binder, JSCore.PropertyAttribute.ReadOnly, null);
			  
		}		
		
		// Load VRbJS and optionally 'opal-parser'
		public void init_opal(bool parser=false, string[] argv = new string[0]) {
			//debug("INIT_OPAL: 001");
			
			// VRbJS runtime and parser
			context.exec(VRbJS.OPAL+VRbJS.OPAL_PARSER);

            var args = "";
            int i = 0;
            foreach (var a in argv) {
				args += @"'$(a)'";
				if (i < argv.length-1) {
					args += ",";
				}
				i += 1;
			}

            // Sets 'ARGV'
            var argv_str = """Opal.casgn(Opal.Object, 'ARGV', [%s]);""".printf(args.escape(null));

            context.exec(argv_str);

            if (parser) {
			// require the parser 
				load_parser();
			}	
		}
		
		public void load_parser() {
				var code = "Opal.require('opal-parser');";
				context.exec(code);			
		}
		
		public bool require(string name, bool no_so=false) {
			//VRbJS.debug_state = true;
			VRbJS.debug("in require\n");
			string path = name;
			bool needs_parser = false;
			
			if (load_so(name) == null || no_so) {
				VRbJS.debug("no so\n");
				if (!f_exist(path) || (!(".rb" in path) || !(".js" in path))) {
					if (!f_exist(path) || (!(".rb" in path) || !(".js" in path))) {
						path = @"./$(name).rb.js";	
						if (!f_exist(path)) {
							path = @"./$(name).rb";			
							if (!f_exist(path)) {					
								path = @"$(lib_dir)/$(name)";
								if (!f_exist(path)) {
									path = @"$(lib_dir)/$(name).rb.js";
									if (!f_exist(path)) {
										path = @"$(lib_dir)/$(name)/$(name).rb.js";
										if (!f_exist(path)) {
											path = @"$(lib_dir)/$(name).rb";
											if (!f_exist(path)) {
												path = @"$(lib_dir)/$(name)/$(name).rb";
												if (!f_exist(path)) {
													JSCore.Value? e;
													var v = jval2gval(context, context.exec("""Opal.require("%s");""".printf(name)).native, out e);
													
													if (e != null) {
														return false;
													}
													return (bool)v;
												}
											}																		
										}							
									}							
								}	
							}
						}
					}			
				} 
			} else {
				require(name, true);
				return true;
			}
			
			if (!f_exist(path)) {
				return false;
			}		
			
			var exts = path.split(".");
			if (exts[exts.length-1] != "js") {
				needs_parser = true;
			}
			
			if ("rb" in exts || "js" in exts) {
				
			} else {
				return false;
			}
			
			if (needs_parser) {
				load(path);
				return true;
			}	
			
			
			
			var code = "";
			FileUtils.get_contents(path, out code, null);
			
			context.exec(code);
			
			return true;
		}
		
		// Loads a ruby file at +path+
		public JSUtils.Value load(string path) {
			load_parser();
			var code = "";
			FileUtils.get_contents(path, out code, null);
			return exec(code);
		}
		
		// Executes ruby source +code+
		public JSUtils.Value exec(string code) {
			//debug("RUNTIME_EXEC: 001");
			
			var s="""eval(Opal.compile("%s"));""".printf(code.escape(null));
			
			var result = context.exec(s);

			return result;
		}
		
		public VRbJS.JSUtils.Binder add_toplevel_class(JSUtils.Binder klass) {
			klass.set_constructor_on(context);
			
			return klass;
		}	
		
		[CCode (has_target = false)]
		public delegate LibInfo? init_lib(VRbJS.Runtime self);
	    public static string? lib_dir;
	    static construct {
			lib_dir = GLib.Environment.get_variable("VRBJS_LIB_DIR") ?? @"/usr/lib/vrbjs/$(VRbJS.VERSION)";			
		}	
		
		public LibInfo? load_so(owned string name) {
			string path = name;
			
			if (!f_exist(path)) {
				path = @"$(name).so";					
				if (!f_exist(path)) {		
					if (!f_exist(path)) {			
						path = @"./$(name)";	
						if (!f_exist(path)) {	
							
							if (!f_exist(path)) {
								path = @"$(lib_dir)/$(name)";
								
								if (!f_exist(path)) {
									path = @"$(lib_dir)/$(name).so";
							   
									if (!f_exist(path)) {
									
										path = @"$(lib_dir)/$(name)/$(name).so";
									}							
								}				
							}
						}
					}
				}
			} else {
				VRbJS.debug(@"Says we have $path");
			}
			
			if (!f_exist(path)) {
				VRbJS.debug("no so found: %s\n".printf(path));
				return null;
			}			
			
			name = GLib.Path.get_basename(path);
			
			var split = name.split(".");
			name = split[0];
			
			VRbJS.debug("FIND_SO: %s\n".printf(path));
			
			if ("so" in split) {
				
			} else {
				return null;
			}
			
			VRbJS.debug(@"so: $name - $path");
			var handle = dlopen(path, RTLD_LAZY);
			var fun    = (init_lib)dlsym(handle, @"$(name)_init");
			
			var binders = fun(this);
            
            VRbJS.debug(@"so $path init-ed");
            
			return binders;
		}	
		
		public bool f_exist(string path) {
			return FileUtils.test (path, FileTest.EXISTS) && !FileUtils.test (path, FileTest.IS_DIR);
		}	
		
		public class LibInfo {
			public Binder?[] interfaces;
			public string? iface_name = null;
			public string? parent_iface = null;
		}
	
	}
}
