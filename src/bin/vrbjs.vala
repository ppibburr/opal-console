namespace VRbJS {
	using JSUtils;
	
#if WEBKIT
	using WebKit;
#endif

	
	private Program program;
	
	public class Program : Runtime {
		public class ProgramBinderKlass : JSUtils.Binder {
	      public ProgramBinderKlass() {
			  base("ProgramBinderClass");
			  
			  bind("apply", (ins, args, c, out e) => {
				  var o = new JSCore.Object(c,target.js_class,null);
				  GLib.Value? n = Type.from_instance(target).name();
				  ((JSUtils.Object)o).set_prop(c, "binder", n);
				 GLib.Value? v = o;
				 return v; 
			  });
			  
			  close();
		  }
		}		
		
		public class ProgramBinder : JSUtils.Binder {
			public Program program {get;private set;}
			
			public ProgramBinder() {
				base("Program", new ProgramBinderKlass());
				
				this.program = program;
				
				bind("append_argv", (self, args, c, out e) => {
					program.append_rargv((string)args[0]);
					
					return null;
				});
				
				bind("dump", (self, args, c, out e) => {
					var what = (string)args[0];
					GLib.Value? res = program.dump(what);
					return res;
				});			

				bind("run", (self, args, c, out e) => {
					string code = "";
					
					if (value_type(args[0]) == ValueType.BOOLEAN) {
						if (FileUtils.test((string)args[5], FileTest.EXISTS)) {
							FileUtils.get_contents((string)args[5], out code, null);
						}
					} else {
						code      = (string)args[0];
					}
					
					var parser    = (bool)args[2];
					var headless  = (bool)args[1];
					var debug     = (bool)args[3];
					var exit      = (bool)args[4];
					var path      = (string)args[5];
					var require   = jsary2vary(c, (JSCore.Object)args[6]);
					
					program.set_file(path);
					
					if (headless) {
#if WEBKIT
					    var uri = "file://"+Runtime.lib_dir+"/html/default.html";
					    
					    if (value_type(args[7]) == ValueType.STRING) {
							uri = (string)args[7];
						}
					    VRbJS.debug("RUN: headless - uri = %s".printf(uri));
						program.execute_headless(code, parser, debug, exit, require, uri);
#else
						stderr.printf("Error: vrbjs not compiled with '-D WEBKIT'\n");
#endif
					} else {
						program.execute(code, parser, true, debug, require);
					}
					
					return null;
				});
				
				bind("read", (self, args, c, out e) => {
					if (value_type(args[0]) != ValueType.STRING) {
						raise(c, "Expects path argument as String", out e);
						return null;
					}
					
					if (FileUtils.test((string)args[0], FileTest.EXISTS)) {
						string buff;
						FileUtils.get_contents((string)args[0], out buff, null);
						GLib.Value? v = buff;
						return v;
					}
					
					raise(c, "#read: File - %s, does not exist.", out e);
					return null;
				});
				
				ValueType?[] w_types = {ValueType.STRING, ValueType.STRING};
				bind("write", (self, args, c, out e) => {
					if (value_type(args[0]) != ValueType.STRING) {
						raise(c, "Expects path argument as String", out e);
						return null;
					}
					
					if (value_type(args[1]) != ValueType.STRING) {
						raise(c, "Expects contents argument as String", out e);
						return null;
					}					
					
					FileUtils.set_contents((string)args[0], (string)args[1]);
					
					return null;
				}, false, 2, w_types);				
				
				close();
			}
			
			public void init(Program prog) {
				this.program = prog;
				
				VRbJS.debug("PROGRAM_INIT: 001");

				init_global(prog.context);
						
				VRbJS.debug("PROGRAM_INIT: 002");
			}			    
		}
		
		public static ProgramBinder binder;
		public static VRbJSModule   vrbjs_module;
		public Program(string[]? argv = null) {
			binder = new ProgramBinder();
			
			base(true, argv);
	
	        add_toplevel_class(binder);
	
			binder.init(this);
			
			init_console();
	
			vrbjs_module         = new VRbJSModule();
			vrbjs_module.runtime = this;

			vrbjs_module.create_toplevel_module(context);


			if (!require("vrbjs", false)) {
				print("CRITICAL: missing vrbjs.rb[.js] file\n");
			}	
	
			if (!require("vrbjs_native")) {
				print("CRITICAL: missing vrbjs_native.rb[.js] file\n");
			}	
	
			require("stdio");
			require("stdio/stderr");
			require("stdio/stdout");	
	
			if (!require("program_lib")) {
				print("CRITICAL: missing program_lib.rb[.js] file\n");
			}
			
			if (!require("program_exec")) {
				print("CRITICAL: missing program_exec.rb[.js] file\n");
			}	
											
		}
		
		public string[] rargv {get; private set; default = new string[0];}
		public string path {get; private set; default = "(file)";}
		
		public void append_rargv(string arg) {
			_rargv += arg;
		}
		
		public void set_file(string path) {
			this._path = path;
		}
		
		public string? dump(string what) {
			if (what == "_core_") {
              var code  = vrbjs_module.generate_bridge_code(context, null,null);	
              code     += binder.prototype.generate_bridge_code(context, null,null);			
			  
			  return code;
			}
			
			
			var info = load_so(what);

            string code = "";

			foreach (var i in info.interfaces) {
				VRbJS.debug("adding iface: %s".printf(Type.from_instance(i).name()));
				code += "\n"+i.generate_bridge_code(context, null, null);
			}
			
			if (info.iface_name != null) {
				var split = code.split("\n");
				
				var buff = "";
				foreach (var l in split) {
					buff += "  "+l+"\n";
				}
				
				code = info.iface_name != null ? @"module $(info.iface_name)\n" : "";
				
				code += buff;
				
				code += "end\n";
			}
			
			return code;
		}
		
		public void execute(string code, bool parser=false, bool console = false, bool debug = false, GLib.Value?[]? require = null, JSUtils.Context? ctx = null) {
			 var opal = new Runner(parser, this.rargv, console, debug, require, ctx);
			 
			 
			 if (parser) {
			   // Expect 'code' as Ruby
			   opal.exec(code);
			   return;
			 }
			 
			 // Expects 'code' as JS
			 opal.context.exec(code);
		}
			
#if WEBKIT
		public void execute_headless(string code, bool parser=false, bool debug = false, bool exit = false, GLib.Value?[]? require = null, string uri) {
			unowned string[] argv = this.argv;
			Gtk.init(ref argv);
			
			mainloop = new GLib.MainLoop(null,true);
			
			webview = new WebKit.WebView();

			WebKit.WebSettings settings = webview.get_settings();

			settings.enable_plugins = true;
			settings.enable_scripts = true;
			settings.enable_universal_access_from_file_uris = true;
			settings.enable_file_access_from_file_uris = true;
			
			// window-object-cleared: does not fire from file:/// uri's unless we do this
			webview.get_main_frame().get_global_context();			

			webview.window_object_cleared.connect( (f,c) => {
				    unowned JSUtils.Context ctx = (VRbJS.JSUtils.Context)c;
				    var obj = (VRbJS.JSUtils.Object)ctx.get_global_object();
				    GLib.Value? v = (int)(void*)webview;
				    
				    // with FFI great things can happen
				    obj.set_prop(ctx, "_vrbjs_webview_address", v);
					
					execute(code, parser, false, debug, require, ctx);
					
					if (exit) {
						mainloop.quit();
					}
			});
			
			webview.console_message.connect((msg)=>{
				print(msg);
				return true;
			});
			
			webview.open(uri);

			mainloop.run();	
		}			
#endif
	}

	public class VRbJSModule : JSUtils.Binder {
	  public Runtime? runtime;
	  public VRbJSModule() {
		  base("VRbJS");

		  type = BinderType.MODULE;
		  
		  bind("set_debug", (self, args, c, out e) => {
			 bool val = (bool)args[0];
			 
			 VRbJS.debug_state = val;
		
			 VRbJS.debug("VRbJS.set_debug(%s)".printf(val ? "true" : "false"));
			 return args[0]; 
		  });
		  
		  bind("require", (self, args, c, out e) => {
			 string what = (string)args[0]; 
			 VRbJS.debug(what);
			 GLib.Value? v = this.runtime.require(what);
			 
			 return v;
		  }, false, 1);
		  
		  bind("exit", (self,args,c, out e) => {
			 int i = (int)(double)args[0];
			 exit(i);
			 return null;
		  },false,1);		  
		  
#if WEBKIT
		  bind("main_quit", () => {
			 mainloop.quit(); 
			 return null;
		  });
		  
		  bind("on_ready", (self, args, c, out e) => {
			 self.protect(c);
	 		 unowned JSCore.Object cb = get_cb(c, args);
			 cb.protect(c);			 
			 webview.notify["load-status"].connect(()=>{
				if (webview.get_load_status() == 2) {
					var a = new GLib.Value?[0];
					call(c, self, cb, a);
				}
			 }); 
			 
			 return null;			 
		  });
#endif
		  
		  close();
	  }	
	}	
	
	
	public class Runner : Runtime {
		public VRbJSModule vrbjs_module;
#if WEBKIT
        public GLib.MainLoop mainloop;
#endif
		public Runner(owned bool parser, string[]? argv = null, bool console = false, bool debug = false, GLib.Value?[]? req_libs = null, JSUtils.Context? ctx = null) {          
			base(parser, argv, ctx);
			
			if (debug) {
				VRbJS.debug_state = true;
			}
			
			if (!require("vrbjs_native", false)) {
				print("CRITICAL: missing vrbjs_native.rb[.js] file\n");
			}
			
			vrbjs_module         = new VRbJSModule();
			vrbjs_module.runtime = this;

			vrbjs_module.create_toplevel_module(context);

			if (!require("vrbjs", false)) {
				print("CRITICAL: missing vrbjs.rb[.js] file\n");
			}

			if (console) {
				init_console();
			}
			
			if (!require("stdio")) {
				stderr.printf("WARN: no stdio.so");
			}
			require("stdio/stderr");
			require("stdio/stdout");
			
			if (!require("file")) {
				stderr.printf("WARN: no file.so");
			}
			
			if (req_libs != null) {
				foreach (var r in req_libs) {
					VRbJS.debug("REQUIRE: %s\n".printf((string)r));
					require((string)r);
				}
			}			
		}
	}
}

GLib.MainLoop mainloop;

#if WEBKIT
WebKit.WebView webview;
#endif

void main(string[] argv) {
  //VRbJS.debug_state = true;sd
  new VRbJS.Program(argv);
}
