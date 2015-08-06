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
					var code      = (string)args[0];
					var parser    = (bool)args[2];
					var headless  = (bool)args[1];
					var debug     = (bool)args[3];
					var exit      = (bool)args[4];
					var path      = (string)args[5];
					var require   = jsary2vary(c, (JSCore.Object)args[6]);
					
					//VRbJS.debug(parser ? "PARSER!\n" : "NO_PARSE\n");
					
					program.set_file(path);
					
					if (headless) {
#if WEBKIT
						program.execute_headless(code, parser, debug, exit, require);
#else
						print("Error: opala not compiled with '-D WEBKIT'\n");
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
		
		public const string WRAPPER = """
(function(Opal) {
  Opal.dynamic_require_severity = "error";
  var self = Opal.top, $scope = Opal, nil = Opal.nil, $breaker = Opal.breaker, $slice = Opal.slice;

  Opal.defs(self, '$read', function(path) {
    var self = this;

    return read(path);
  });
  return (Opal.defs(self, '$write', function(path, contents) {
    var self = this;

    return write(path, contents);
  }), nil) && 'write';
})(Opal);
""";		
		
		public const string PROGRAM = """
!function($){function e($,e){return"number"==typeof $&&"number"==typeof e?$+e:$["$+"](e)}$.dynamic_require_severity="error";var t,s,n,r=$.top,i=$,o=$.nil,a=($.breaker,$.slice,$.module),l=$.klass,u=$.hash2,p=$.gvars,c=$.range,g=o,h=o,f=o,d=o,b=o;null==p[0]&&(p[0]=o),$.add_stubs(["$split","$!","$empty?","$=~","$first","$index","$raise","$==","$[]","$shift","$nil?","$map","$include?","$<<","$has_key?","$[]=","$flatten","$puts","$print","$ljust","$getopts","$usage","$length","$read","$last","$write","$each"]),function(t){{var s=a(t,"Getopt");s.$$proto,s.$$scope}!function(t,s){function n(){}var r=n=l(t,s,"Std",n),i=(r.$$proto,r.$$scope);return function($,e){function t(){}{var s=t=l($,e,"Error",t);s.$$proto,s.$$scope}return o}(r,i.get("StandardError")),$.cdecl(i,"VERSION","1.4.2"),$.defs(r,"$getopts",function($){var t,s,n,r,a=this,l=o,g=o,h=o,f=o,d=o,b=o,_=o;for(l=$.$split(/ */),g=u([],{});s=i.get("ARGV")["$empty?"]()["$!"](),(t=s!==!1&&s!==o?i.get("ARGV").$first()["$=~"](/^-(.)(.*)/):s)!==o&&(!t.$$is_boolean||1==t);)t=[(s=p["~"])===o?o:s["$[]"](1),(s=p["~"])===o?o:s["$[]"](2)],h=t[0],f=t[1],d=$.$index(h),d!==!1&&d!==o||a.$raise(i.get("Error"),"invalid option '"+h+"'"),l["$[]"](e(d,1))["$=="](":")?(i.get("ARGV").$shift(),(t=f["$empty?"]())===o||t.$$is_boolean&&1!=t?(t=(r=l["$include?"](f))!==!1&&r!==o?r:l["$include?"](f["$[]"](c(1,-1,!1))))===o||t.$$is_boolean&&1!=t||(_="cannot use switch '"+f+"' as argument ",_=e(_,"to another switch"),a.$raise(i.get("Error"),_)):(f=i.get("ARGV").$shift(),(t=(s=f["$nil?"]())!==!1&&s!==o?s:f["$empty?"]())===o||t.$$is_boolean&&1!=t||a.$raise(i.get("Error"),"missing argument for '-"+l["$[]"](d)+"'"),b=(t=(s=l).$map,t.$$p=(n=function($){n.$$s||this;return null==$&&($=o),"-"+$},n.$$s=a,n),t).call(s),(t=(r=b["$include?"](f))!==!1&&r!==o?r:b["$include?"](f["$[]"](c(1,-1,!1))))===o||t.$$is_boolean&&1!=t||(_="cannot use switch '"+f+"' as argument ",_["$<<"]("to another switch"),a.$raise(i.get("Error"),_)),(t=g["$has_key?"](h))===o||t.$$is_boolean&&1!=t?g["$[]="](h,f):g["$[]="](h,[g["$[]"](h),f].$flatten()))):(g["$[]="](h,!0),(t=f["$empty?"]())===o||t.$$is_boolean&&1!=t?i.get("ARGV")["$[]="](0,"-"+f):i.get("ARGV").$shift());return g}),o&&"getopts"}(s,null)}(r),i.get("ARGV").$shift(),$.cdecl(i,"VERSION","0.1.0"),$.cdecl(i,"OPTIONS",u(["e","v","h","w","c","j","s"],{e:"Execute inline ruby script",v:"Print version",h:"Print this message",w:"run in headless WebKit",c:"Transpile ruby source to JS",j:"Execute inline js",s:"include stdlib"})),$.Object.$$proto.$usage=function($){var t,s,n,r=this;return null==$&&($=""),r.$puts($),r.$puts("opala - A ruby source runner/transpiler via Opal in JavaScriptCore\n\n"),r.$puts("Usage:"),r.$puts("opala [OPTIONs] [PATH|CODE]\n\n"),r.$puts("OPTIONS:"),(t=(s=i.get("OPTIONS")).$map,t.$$p=(n=function($,t){var s=n.$$s||this;return null==$&&($=o),null==t&&(t=o),s.$print(e(("-"+$).$ljust(10),""+t+"\n"))},n.$$s=r,n),t).call(s)};try{return g=i.get("Getopt").$$scope.get("Std").$getopts("vhwcejs"),p[0]="(file)",(t=(s=g["$[]"]("v"))!==!1&&s!==o?s:g["$[]"]("h"))===o||t.$$is_boolean&&1!=t?(t=g["$[]"]("c"))===o||t.$$is_boolean&&1!=t?(p[0]="(file)",f=!0,(t=g["$[]"]("e"))===o||t.$$is_boolean&&1!=t?(t=g["$[]"]("j"))===o||t.$$is_boolean&&1!=t?(p[0]=i.get("ARGV").$shift(),d=r.$read(p[0]),(t=(s=i.get("ARGV")).$each,t.$$p=(n=function($){n.$$s||this;return null==$&&($=o),append_argv($)},n.$$s=r,n),t).call(s),(t=p[0].$split(".").$last()["$=="]("rb")["$!"]())===o||t.$$is_boolean&&1!=t||(f=!1)):(d=i.get("ARGV").$last(),f=!1):d=i.get("ARGV").$last(),run(d,g["$[]"]("w")["$!"]()["$!"](),f,p[0],g["$[]"]("s")["$=="](o)["$!"]())):((t=g.$length()["$=="](1)["$!"]())===o||t.$$is_boolean&&1!=t||r.$raise("Too many options passed. -c takes 0 options"),h=r.$read(i.get("ARGV").$last()),$.require("opal-parser"),r.$write(e(i.get("ARGV").$last(),".js"),$.compile(h))):((t=g["$[]"]("v"))===o||t.$$is_boolean&&1!=t||r.$puts(i.get("VERSION")),(t=g["$[]"]("h"))===o||t.$$is_boolean&&1!=t?o:r.$usage())}catch(_){return b=_,r.$usage(b)}}(Opal);
"""; 	
		
		public Program(string[]? argv = null) {
			var binder = new ProgramBinder();
			
			base(true, argv);
	
	        add_toplevel_class(binder);
	
			binder.init(this);
			
			init_console();
	
			var pt = new VRbJSPrototype();
			pt.runtime = this;

			pt.create_toplevel_module(context);

			require("vrbjs", false);	
	
			if (!require("native")) {
				print("CRITICAL: missing native.rb[.js] file\n");
			}	
	
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
			var info = load_so(what);

            string code = "";

			foreach (var binder in info.interfaces) {
				code += "\n"+binder.generate_bridge_code(context, null, null);
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
		public void execute_headless(string code, bool parser=false, bool debug = false, bool exit = false, GLib.Value?[]? require = null) {
			unowned string[] argv = this.argv;
			Gtk.init(ref argv);
			var webview = new WebKit.WebView();

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
				    
				    obj.set_prop(ctx, "_vrbjs_webview_address", v);
					
					execute(code, parser, false, debug, require, ctx);
					
					if (exit) {
						Gtk.main_quit();
					}
			});
			
			webview.open(@"file://$(Runtime.lib_dir)/html/default.html");

			Gtk.main();	
		}			
#endif
	}

	public class VRbJSPrototype : JSUtils.Binder {
	  public Runtime? runtime;
	  public VRbJSPrototype() {
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
		  
		  close();
	  }	
	}	
	
	
	public class Runner : Runtime {
		public VRbJSPrototype pt;
		
		public Runner(owned bool parser, string[]? argv = null, bool console = false, bool debug = false, GLib.Value?[]? req_libs = null, JSUtils.Context? ctx = null) {          
			base(parser, argv, ctx);
			
			if (debug) {
				VRbJS.debug_state = true;
			}
			
			require("native", false);
			
			this.pt = new VRbJSPrototype();
			pt.runtime = this;

			pt.create_toplevel_module(context);

			require("vrbjs", false);

			if (console) {
				init_console();
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


void main(string[] argv) {
  //VRbJS.debug_state = true;sd
  new VRbJS.Program(argv);
}
