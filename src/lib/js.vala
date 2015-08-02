namespace Opal{
	namespace JSUtils {
public enum ValueType {
				NULL,
				OBJECT,
				STRING,
				DOUBLE,
				FLOAT,
				INT,
				BOOLEAN
			}
			
			public enum ObjectType {
				OBJECT,
				FUNCTION,
				CONSTRUCTOR,
				ARRAY;
				
				public static ObjectType from_object(JSCore.Context c, JSCore.Object obj) {
					if (obj.is_function(c)) {
						return FUNCTION;
					} else if (obj.is_constructor(c)) {
						return CONSTRUCTOR;
					} else {
						var code = new JSCore.String.with_utf8_c_string("Array.isArray(this);");
						var v = c.evaluate_script(code, obj, null, 0, null);
						if (v.is_boolean(c) && v.to_boolean(c) ) {
							return ARRAY;
						} else {
							return OBJECT;
						}
					}
				}
			}
			
			public static ValueType value_type(GLib.Value? val) {
				if (val == null) {
					return ValueType.NULL;
				}
				
				if (val.holds(typeof(string))) {
					return ValueType.STRING;
				} else if (val.holds(typeof(bool))) {
					return ValueType.BOOLEAN;
				} else if (val.holds(typeof(double))) {
					return ValueType.DOUBLE;
				} else if (val.holds(typeof(float))) {
					return ValueType.FLOAT;	
				} else if (val.holds(typeof(int))) {
					return ValueType.INT;				
				} else if (val.holds(typeof(void*))) {
					return ValueType.OBJECT;
				} else {
					return ValueType.NULL;
				}
			}
			
			public static GLib.Value?[] jsary2vary(JSCore.Context c, JSCore.Object obj) {
				// TODO:
				int len = (int)obj.get_property(c, new JSCore.String.with_utf8_c_string("length"), null).to_number(c,null);
				
				GLib.Value?[] vals = new GLib.Value?[len];
				
				for (var i = 0; i < len; i++) {
					var v = obj.get_property(c, new JSCore.String.with_utf8_c_string(@"$i"), null);
					vals[i] = jval2gval(c, v, null);
				}
				
				return vals;
			}			
			
			public static GLib.Value? jval2gval(JSCore.Context c, JSCore.Value arg, out JSCore.Value e) {
				GLib.Value? v = null;
				
				if (arg.is_string(c)) {
					v = JSUtils.Context._read_string(c, arg);
					
				} else if (arg.is_number(c)) {
					v = arg.to_number(c, null);
					
				} else if (arg.is_boolean(c)) {
					v = arg.to_boolean(c);
					
				} else if (arg.is_null(c)) {
					v = null;
					
				} else if (arg.is_object(c)) {
					v = arg.to_object(c, null);			
				} else {
					JSUtils.Value.string(c, "Bad Conversion", out e);
					return null;
				}
				
				
				return v;		
			}				
			
			
			public static JSCore.Value gval2jval(JSCore.Context c, GLib.Value? val) {
				switch (value_type(val)) {
				case ValueType.STRING:
				  JSCore.Value? v = null;
				  JSUtils.Value.string(c, (string)val, out v);
				  return v;
				  
				case ValueType.DOUBLE:  
				  return new JSCore.Value.number(c, (double)val);

				case ValueType.FLOAT:  
				  return new JSCore.Value.number(c, (double)(float)val);
				  
				case ValueType.INT:  
				  return new JSCore.Value.number(c, (double)(int)val);				  

				case ValueType.BOOLEAN:  
				  return new JSCore.Value.boolean(c, (bool)val);
				  
				case ValueType.OBJECT:  
				  return c.evaluate_script(new JSCore.String.with_utf8_c_string("this;"), (JSCore.Object)val, null, 0, null);
				  
				default:
				  return new JSCore.Value.null(c);
				}		
			}	
			
			
			public static JSCore.Value string_value(JSCore.Context c, string val) {
				Opal.debug("STRING_VALUE: 001");
				JSCore.Value j;
				JSUtils.Value.string(c, val, out j);
				Opal.debug("STRING_VALUE: 002");				
				return j;
			}
			
			public static GLib.Value? call(JSCore.Context c, JSCore.Object self, JSCore.Object fun, GLib.Value?[] args) {
			
				void*[] jargs = {};
				int i = 0;
				
				foreach (var v in args) {
					jargs += (void*)gval2jval(c, v);
					i++;
				}
				
				unowned JSCore.Value res = fun.call_as_function(c, self, (JSCore.Value[]?)jargs, null);

				return jval2gval(c,res,null);
			}
			
			public string v2str(GLib.Value? val) {
				switch (value_type(val)) {
				case ValueType.NULL:
					return "(NULL)";
				
				case ValueType.BOOLEAN:
					return val.get_boolean().to_string();
				
				case ValueType.DOUBLE:
					double d = val.get_double();
					return d.to_string();
					
				case ValueType.FLOAT:
					double d = val.get_float();
					return d.to_string();
				
				case ValueType.INT:
					double d = val.get_int();
					return d.to_string();										
					
				case ValueType.STRING:
					return (string)val;
				  
				case ValueType.OBJECT:
					return "[Object]";
				
				default:
				  return "(NULL)";
				}	
			}
			
			public static string object_to_string(JSCore.Context c, JSCore.Object obj) {
				return JSUtils.Context._read_string(c,c.evaluate_script(new JSCore.String.with_utf8_c_string("this.toString();"), obj, null, 0, null));
			}				
		
		public class Object : JSCore.Object {
			public Object(JSUtils.Context c, JSCore.Class? klass=null, void* data=null) {
				base(c,klass,data);
			}
			
			public void set_prop(JSCore.Context c, string name, GLib.Value? v) {
				var js = new JSCore.String.with_utf8_c_string(name);
				set_property(c, js, gval2jval(c, v), JSCore.PropertyAttribute.ReadOnly, null);
			}
			
			public GLib.Value? get_prop(JSCore.Context c, string name) {
				var js = new JSCore.String.with_utf8_c_string(name);
				return jval2gval(c, get_property(c, js, null), null);
			}			
		}
		
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
				retain();
			}
			
			public Value exec(string code) {
				var e = new JSCore.Value.null(this);
				var js = new JSCore.String.with_utf8_c_string(code);
				var result = new Value(this, ((JSCore.Context)this).evaluate_script(js, null, null, 0, out e));

				if (e != null) {
					if (!e.is_null(this)) {
						print("ERROR: %s\n",read_string(e));
					}
				}
				return result;
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
}
