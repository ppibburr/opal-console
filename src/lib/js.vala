namespace VRbJS{
	namespace JSUtils {
		public static void raise(JSCore.Context ctx, string msg, out JSCore.Value err) {
			GLib.Value?[] args = new GLib.Value?[1];
			args[0] = msg;
			err = (JSCore.Value)new JSCore.Object.error(ctx, 1, vary2jary(ctx, args), null);
		}
	
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
		
		public string jval2string(JSCore.Context c, JSCore.Value v, out JSCore.Value e) {
			var j   = v.to_string_copy(c, v);
			var len = j.get_length()+1;
			
			char[] buff = new char[len];
			
			j.get_utf8_c_string(buff, len);
			
			return (string)buff;
		}
		
		public static GLib.Value? jval2gval(JSCore.Context c, JSCore.Value arg, out JSCore.Value e) {
			GLib.Value? v = null;
			
			if (arg.is_string(c)) {
				v = jval2string(c, arg, out e);
			
			} else if (arg.is_number(c)) {
				v = arg.to_number(c, null);
				
			} else if (arg.is_boolean(c)) {
				v = arg.to_boolean(c);
				
			} else if (arg.is_null(c)) {
				v = null;
				
			} else if (arg.is_object(c)) {
				v = arg.to_object(c, null);			
			
			} else {
				raise(c, "Bad Conversion", out e);
				
				return null;
			}
			
			
			return v;		
		}				
		
		
		public static JSCore.Value gval2jval(JSCore.Context c, GLib.Value? val) {
			switch (value_type(val)) {
			case ValueType.STRING:
			  JSCore.Value? v = new JSCore.Value.string(c, new JSCore.String.with_utf8_c_string((string)val));
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
		
		public static void*[] vary2jary(JSCore.Context c, GLib.Value?[] args) {
			void*[] jargs = {};
			int i = 0;
			
			foreach (var v in args) {
				jargs += (void*)gval2jval(c, v);
				i++;
			}
			
			return jargs;			
		}
		
		public static GLib.Value? call(JSCore.Context c, JSCore.Object self, JSCore.Object fun, GLib.Value?[] args) {
			var jargs = vary2jary(c, args);
			
			unowned JSCore.Value res = fun.call_as_function(c, self, (JSCore.Value[]?)jargs, null);

			return jval2gval(c,res,null);
		}
		
		public string v2str(GLib.Value? val, JSCore.Context? c = null) {
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
				return c != null ? object_to_string(c, (JSCore.Object)val) : "[Object]";
			
			default:
			  return "(NULL)";
			}	
		}
		
		public static string object_to_string(JSCore.Context c, JSCore.Object obj) {
			return (string)jval2gval(c, c.evaluate_script(new JSCore.String.with_utf8_c_string("this.toString();"), obj, null, 0, null), null);
		}				
		
		public class Object : JSCore.Object {
			public Object(JSCore.Context c, JSCore.Class? klass=null, void* data=null) {
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
			
			public GLib.Value? to_gval() {
				GLib.Value? v = this;
				return v;
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
			
			public GLib.Value? exec(string code, JSCore.Object? self = null, out JSCore.Value e = null) {
				var js = new JSCore.String.with_utf8_c_string(code);
				//JSCore.Value e2;
				var result = jval2gval(this, ((JSCore.Context)this).evaluate_script(js, null, null, 0, out e), null);

				return result;
			}	
			
			// Initializes libseed in this context
			[CCode (has_target = false)]
			public delegate void init_seed_sig(int argc, string** argv, void* ctx);
			public void init_seed(string[] argv) {

				var handle = dlopen("libseed-gtk3.so", RTLD_LAZY);
				var func   = dlsym(handle, "seed_init_with_context");

				((init_seed_sig)func)(0, null, (void*)this);
			}
		}
	}
}
