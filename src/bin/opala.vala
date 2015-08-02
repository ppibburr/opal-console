namespace Opala {
	using Opal;
	using JSUtils;
	using WebKit;
	
	public const string OPALA_VERSION = "0.1.0";
	
	private Program program;
	
	public class Program : Runtime {
		public class ProgramBinder : JSUtils.Binder {
			public Program program {get;private set;}
			
			public ProgramBinder() {
				base("Program");
				
				this.program = program;
				
				bind("append_argv", (self, args, c, out e) => {
					program.append_rargv((string)args[0]);
					
					return null;
				});

				bind("run", (self, args, c, out e) => {
					var code     = (string)args[0];
					var parser   = (bool)args[2];
					var headless = (bool)args[1];
					var path     = (string)args[3];
					var stdlib   = args[4] != null ? (bool)args[4] : false;
					
					//Opal.debug(parser ? "PARSER!\n" : "NO_PARSE\n");
					
					program.set_file(path);
					
					if (headless) {
						program.execute_headless(code, parser, stdlib);
					} else {
						program.execute(code, parser, true, stdlib);
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
				}, 2);				
				
				close();
			}
			
			public void init(Program prog) {
				this.program = prog;
				
				Opal.debug("PROGRAM_INIT: 001");

				init_global(prog.context);
				
				Opal.debug("PROGRAM_INIT: 002");
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
			
			var c = new JSUtils.Context(binder.js_class);
			
			base(false, argv, c);
			
			binder.init(this);
			
			init_console();
			
			context.exec(WRAPPER+PROGRAM);			
		}
		
		public string[] rargv {get; private set; default = new string[0];}
		public string path {get; private set; default = "(file)";}
		
		public void append_rargv(string arg) {
			_rargv += arg;
		}
		
		public void set_file(string path) {
			this._path = path;
		}
		
		public void execute(string code, bool parser=false, bool console = false, bool stdlib = false, JSUtils.Context? ctx = null) {
			 var opal = new Runner(parser, this.rargv, console, stdlib, ctx);
			 
			 if (parser) {
			   // Expect 'code' as Ruby
			   opal.exec(code);
			   return;
			 }
			 
			 // Expects 'code' as JS
			 opal.context.exec(code);
		}
			

		public void execute_headless(string code, bool parser=false, bool stdlib = false) {
			unowned string[] argv = this.argv;
			Gtk.init(ref argv);
			var webview = new WebKit.WebView();

			WebKit.WebSettings settings = webview.get_settings();

			settings.enable_plugins = true;
			settings.enable_scripts = true;
			settings.enable_universal_access_from_file_uris = true;
			
			webview.window_object_cleared.connect( (f,c) => {
					execute(code, parser, false, stdlib, (Opal.JSUtils.Context)c);
					Gtk.main_quit();
			});
			
			webview.open("file:///foo.html");

			Gtk.main();	
		}			
	}
	
	public class Runner : Runtime {
		public class OpalaPrototype : JSUtils.Binder {
		  public OpalaPrototype() {
			  base("Opala");
			  
			  bind("set_debug", (self, args, c, out e) => {
				 bool val = (bool)args[0];
				 
				 Opal.debug_state = val;
				 print("called\n");
				 Opal.debug("Opala.set_debug(%s)".printf(val ? "true" : "false"));
				 return args[0]; 
			  });
			  
			  close();
		  }	
		}
				
		public OpalaPrototype pt;
		
		public const string REM_CORE_FILE = """(function(Opal) {
  Opal.dynamic_require_severity = "error";
  var self = Opal.top, $scope = Opal, nil = Opal.nil, $breaker = Opal.breaker, $slice = Opal.slice;

  Opal.add_stubs(['$send']);
  return $scope.get('Object').$send("remove_const", $scope.get('File'))
})(Opal);""";
		
		public const string OPALA_NATIVE_WRAPPER = """!function(e){e.dynamic_require_severity="error";var t=e.top,n=e.nil,a=(e.breaker,e.slice),i=e.module,r=e.klass;return e.add_stubs(["$new","$set_native_type","$native_type","$allocate","$send","$_native=","$attr_accessor"]),function(t){var $=i(t,"Opala"),s=($.$$proto,$.$$scope);e.defs($,"$Interface",function(e){var t=n;return t=s.get("Class").$new(s.get("Opala").$$scope.get("Object")),t.$set_native_type(e),t}),function(t,i){function $(){}{var s,l=$=r(t,i,"Object",$);l.$$proto,l.$$scope}return e.defs(l,"$inherited",function(e){var t=this;return e.$set_native_type(t.$native_type())}),e.defs(l,"$set_native_type",function(e){var t=this;return t.native_type=e}),e.defs(l,"$native_type",function(){var e=this;return null==e.native_type&&(e.native_type=n),e.native_type}),e.defs(l,"$new",function(e){var t,i,r=this,$=n;return e=a.call(arguments,0),$=r.$allocate(),$.$send("initialize"),t=[r.$native_type().apply(Object.create(null),e)],i=$,i["$_native="].apply(i,t),t[t.length-1],$}),e.defs(l,"$wrap",s=function(e,t){var i,r,$=this,l=(s.$$p,n);return t=a.call(arguments,1),s.$$p=null,l=$.$allocate(),l.$send("initialize"),i=[e],r=l,r["$_native="].apply(r,i),i[i.length-1],l}),l.$attr_accessor("_native")}($,null)}(t)}(Opal);""";

		
		public Runner(owned bool parser, string[]? argv = null, bool console = false, bool stdlib = false, JSUtils.Context? ctx = null) {
            if (stdlib && !FileUtils.test("opala-stdlib", FileTest.EXISTS)) {
				parser = true;
			}
          
          
			base(parser, argv, ctx);
			
			this.pt = new OpalaPrototype();
			pt.create_toplevel_module(context);
			
			if (stdlib) {
				context.exec(REM_CORE_FILE + OPALA_NATIVE_WRAPPER);				
				var klass = new Opal.StandardLibrary.JFile();
				add_toplevel_class(klass);
				
				if (!FileUtils.test("opala-stdlib", FileTest.EXISTS)) {
					var js = klass.prototype.compile_bridge_code(context, klass, null);
					print("\n\n\n\n\n%s\n\n\n\n", js);
					context.exec(js);
				} else {
					string code;
					FileUtils.get_contents("opala-stdlib/file.rb.js", out code, null);
					context.exec(code);
				}
				Opal.debug_state = true;
				var funcb = new Opal.JsFFI.FFIFuncBinder();
				funcb.default_context = context;
				
				add_toplevel_class(funcb);
				add_toplevel_class(funcb.pointer_binder);
				
				if (!FileUtils.test("opala-stdlib/ffi_func.rb.js", FileTest.EXISTS)) {
					var js = funcb.prototype.compile_bridge_code(context, funcb, null);
					Opal.debug("\n\n\n\n\n%s\n\n\n\n".printf(js));
					context.exec(js);
				} else {
					string code;
					FileUtils.get_contents("opala-stdlib/ffi_func.rb.js", out code, null);
					context.exec(code);
				}	
				
				if (!FileUtils.test("opala-stdlib/ffi_pointer.rb.js", FileTest.EXISTS)) {
					var js = funcb.pointer_binder.prototype.compile_bridge_code(context, funcb.pointer_binder, null);
					Opal.debug("\n\n\n\n\n%s\n\n\n\n".printf(js));
					context.exec(js);
				} else {
					string code;
					FileUtils.get_contents("opala-stdlib/ffi_pointer.rb.js", out code, null);
					context.exec(code);
				}						
				
			}
			
			if (console) {
				init_console();
			}
		}
	}
}


void main(string[] argv) {
  //Opal.debug_state = true;sd
  new Opala.Program(argv);
}
