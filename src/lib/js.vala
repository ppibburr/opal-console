namespace JS {
	public class Value {
		private weak JSCore.Context _context;
		private weak JSCore.Value? _native;
		public JSCore.Context context {
			get {return _context;}
			private set {
				this._context = value;
			}
		}
		
		public JSCore.Value? native {
			get {return _native;}
			private set {
				this._native = value;
			}
		}		
		
		public Value(JSCore.Context ctx, JSCore.Value? native) {
			this.native = native;
			this.context = ctx;
		}
		
		public static void string(JSCore.Context ctx, string str, out JSCore.Value val) {
			var j = new JSCore.String.with_utf8_c_string(str);
			val = new JSCore.Value.string(ctx, j);
		}
		
		public string to_string() {
			return Context._read_string(context, native);
		}
		
		public JSCore.Object to_object() {
			return native.to_object(context, null);
		}
	}

	public class Context : JSCore.GlobalContext {
		public JSCore.Object global_object() {
			return ((JSCore.Context)this).get_global_object();			
		}
		
		public Context(JSCore.Class? kls=null) {
			base(kls);
			init_console();
		}
		
		public Value exec(string code) {
			var js = new JSCore.String.with_utf8_c_string(code);
			return new Value(this, ((JSCore.Context)this).evaluate_script(js, null, null, 0, null));
		}
		
		private void init_console() {
		  var console = exec("var console = {};console;").to_object();
	;
		  var name = new JSCore.String.with_utf8_c_string("log");
		
		
		  console.set_property((JSCore.Context)this,
						name,
						new JSCore.Object.function_with_callback((JSCore.Context)this, name, (a, b, c, d, e) => {
							e = null;		
							print("%s",_read_string(a, d[0]));	
							return new JSCore.Value.null(a);
						}),
						JSCore.PropertyAttribute.ReadOnly,
						null);
						
		  print("console: Ready.\n");
		}
		
		public static string _read_string(JSCore.Context ctx, JSCore.Value val) {
			var jstr = val.to_string_copy(ctx, null);
			var size = jstr.get_length()+1;
			var buff = new char[size];
			jstr.get_utf8_c_string(buff, size);
			return((string)buff);	  
		}
		
		public string read_string(JSCore.Value val) {
		  return  _read_string(this, val);	
		}	
	}
}
