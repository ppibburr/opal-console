namespace Opal {
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
            
            //Opal.debug("RUNTIME: 001");

			init_opal(this.context, parser, argv);
			
			//Opal.debug("RUNTIME: 002");
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
		
		// Load Opal and optionally 'opal-parser'
		public static void init_opal(Context context, bool parser=false, string[] argv = new string[0]) {
			//debug("INIT_OPAL: 001");
			
			// Opal runtime and parser
			context.exec(Opal.OPAL+Opal.OPAL_PARSER);

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
				var code = "Opal.require('opal-parser');";
				context.exec(code);
			}	
		}
		
		public JSUtils.Value require(string what) {
			return context.exec("""Opal.require("%s")""".printf(what));
		}
		
		// Loads a ruby file at +path+
		public JSUtils.Value load(string path) {
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
		
		public Opal.JSUtils.Binder add_toplevel_class(JSUtils.Binder klass) {
			klass.set_constructor_on(context);
			
			return klass;
		}	
	
	}
}
