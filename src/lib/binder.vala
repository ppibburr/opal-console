
namespace VRbJS {
	namespace JSUtils {
		public class Binder {
			public class BCB {
				public Binder.b_cb func;
				public string name;
				public int n_args = -1;
				public ValueType?[] atypes;
				public string[]? anames;
				public BCB(string n, int n_args, ValueType?[] atypes = null, string[]? anames = null, Binder.b_cb func) {
					this.func = func;
					this.name = n;
					this.n_args = n_args;
					this.atypes = atypes;
					this.anames = anames;
				}
			}
			
			
			public JSCore.StaticFunction[] static_functions {get; private set;}
			public JSCore.ClassDefinition definition;
			public JSCore.Class js_class;
			public Binder? prototype;
			public Binder? target;
			public string? rb_name = null;
			
			public Binder(string class_name, Binder? prototype = null) {
				this.definition = JSCore.ClassDefinition();
				this.definition.className = class_name;
				this.prototype = prototype;
				
				if (prototype != null) {
					prototype.target = this;
				}
				
				
			}
			
			public void close() {
				ensure_init(this);
				var sf = new JSCore.StaticFunction[static_functions.length+1];
				
				for (var i = 0; i < static_functions.length; i++) {
					sf[i] = static_functions[i];
				}
				
				this.definition.staticFunctions = (JSCore.StaticFunction*)sf;
			
				this.js_class = new JSCore.Class(ref definition);
			
				Type.from_instance(this).set_qdata(Quark.from_string("jsclass"), this.js_class);
			}
			
			public delegate GLib.Value? b_cb(JSCore.Object self, GLib.Value?[] args, JSCore.Context c, out JSCore.Value e);
			
			public static string[] constructors {get;private set; default=new string[0];}
			
			public static void add_constructor(string name) {
				if (name in constructors) {
				} else{
					_constructors += name;
				}
			}
			
			public virtual void bind(string name, b_cb cb, bool constructor = false, int n_args = -1, ValueType?[] atypes = null, string[]? anames = null) {
				if (constructor) {
				  add_constructor(name);	
				}
				
				set_binding(name, n_args, atypes, anames, cb);
				
				var sfun = JSCore.StaticFunction() {
					name = name,
					attributes = JSCore.PropertyAttribute.ReadOnly,
					
				
					
					callAsFunction = (c, fun, self, a, out e) => {
						//print("Hahaha\n");
						var static_binder = (string?)((JSUtils.Object)self).get_prop(c, "static_binder");
						var tname         = (string?)((JSUtils.Object)fun).get_prop(c, "name");
						var binder        = (string?)((JSUtils.Object)self).get_prop(c, "binder");
						//print("EOHahaha\n");
								
						var args = new GLib.Value?[0];
						foreach (unowned JSCore.ConstValue v in a) {
							args += jval2gval(c, (JSCore.Value)v, out e);
						}								
								
				        VRbJS.debug("bound_static_function: static_binder - %s, binder - %s, func_name - %s".printf(static_binder, binder, tname));
						var func = get_binding(binder, tname) ?? get_binding(static_binder, tname);
						
						if (func.n_args != -1 && a.length > func.n_args) {
							raise(c, "Too many arguments passed to %s, %d for %d".printf(func.name, a.length, func.n_args), out e);
							return null;
						}
						
						if (func.n_args != -1 && a.length < func.n_args) {
							raise(c, "Too few arguments passed to %s, %d for %d".printf(func.name, a.length, func.n_args), out e);
							return null;
						}	
						
						if (func.n_args > 0) {
							if (func.atypes != null) {
								int? idx = check_args(args, func.atypes);
								
								if (idx != null ) {
									raise(c, "ArgumentError: argument %d expects %s".printf(idx+1, func.anames != null ? func.anames[(int)idx] : func.atypes[(int)idx].to_string()), out e);
									return null;
								} 
							}
						}						
						
						if (e != null) {
							return new JSCore.Value.null(c);
						}
					
						GLib.Value? val = func.func(self, args, c, out e);

						JSCore.Value jv = gval2jval(c, val);
						
						return jv;
					}
				};
				
				_static_functions += sfun;	
			}
			
			
			public void set_binding(string n, int n_args = -1, ValueType?[] atypes = null, string[]? anames = null, b_cb cb) {
				ensure_init(this);
				var bcb = new BCB(n, n_args, atypes, anames, cb);
				((Gee.HashMap<string, BCB>)Type.from_instance(this).get_qdata(Quark.from_string("map")))[n] = bcb;
			}
			
			public static BCB get_binding(string binder, string name) {
				return ((Gee.HashMap<string, BCB>)Type.from_name(binder).get_qdata(Quark.from_string("map")))[name];
			}
		   
			public static void ensure_init(Binder target) {
				if ((Gee.HashMap<string, BCB>?)Type.from_instance(target).get_qdata(Quark.from_string("map")) == null) {
					Type.from_instance(target).set_qdata(Quark.from_string("map"), new Gee.HashMap<string, BCB>());
				}
			}
			
			public static void raise(JSCore.Context ctx, string msg, out JSCore.Value err) {
			  JSUtils.Value.string(ctx, msg, out err);	
			}
			
			public delegate void i_cb(JSCore.Context c, JSCore.Object o);
			public delegate void f_cb(JSCore.Object o);	
			public delegate void c_cb(JSCore.Object instance, GLib.Value?[] args, JSCore.Context c, out JSCore.Value err);		
			
			public void initializer(i_cb cb) {
				
			}
			
			public void finalizer(f_cb cb) {
				
			}
			
			public void constructor(c_cb cb) {
				Type.from_instance(this).set_qdata(Quark.from_string("constructor"),(void*) cb);
			}
			
			public JSCore.Object set_constructor_on(JSCore.Context c, owned JSCore.Object? t=null, owned Binder? prototype_class = null) {
				debug("SET_CONSTRUCT: 001");
				
				if (prototype_class == null) {
					prototype_class = this.prototype;
				}
				
		;
				if (t==null) {
					t = c.get_global_object();
				}
				
				var con = new JSCore.Object.constructor(c, this.js_class, (ctx, self, args, out e)=>{
				 
					var binder = new JSCore.String.with_utf8_c_string("binder");
					var type_name = JSUtils.Context._read_string(ctx,self.get_property(ctx, binder, null));
					
					unowned JSCore.Class jc = (JSCore.Class)Type.from_name(type_name).get_qdata(Quark.from_string("jsclass"));
					Binder.c_cb? cb = (Binder.c_cb?)Type.from_name(type_name).get_qdata(Quark.from_string("constructor"));
			
					var obj = new JSCore.Object(ctx, jc, (void*)"foo\n");
					
					obj.set_property(ctx, binder, string_value(ctx, type_name), JSCore.PropertyAttribute.ReadOnly, null);			
					
					if (cb != null) {
						GLib.Value?[] vary = new GLib.Value?[0];
						
						foreach (unowned JSCore.Value v in args) {
							vary += jval2gval(ctx, v, out e);
						}				
						
						cb(obj, vary, ctx, out e);
					}
					
					
					
					return obj;
				});
				
				Type.from_instance(this).set_qdata(Quark.from_string("jsconstructor"), (void*)con);
				
				con.set_property(c, new JSCore.String.with_utf8_c_string("binder"), string_value(c, Type.from_instance(this).name()), JSCore.PropertyAttribute.ReadOnly, null);	
				
				t.set_property(
					c,
					new JSCore.String.with_utf8_c_string(this.definition.className),
					con,
					JSCore.PropertyAttribute.ReadOnly,
					null);
					
				if (prototype_class != null) {
					prototype_class.set_as_prototype(c, con);
				}	
				
				debug("SET_CONSTRUCT: 002");
				return con;
			}
			
			public JSCore.Object create_toplevel_module(JSCore.Context c) {
				var m = new JSCore.Object(c, this.js_class, null);
				var o = c.get_global_object();
				
				GLib.Value v = Type.from_instance(this).name();
				m.set_property(c, new JSCore.String.with_utf8_c_string("static_binder"), gval2jval(c,v), JSCore.PropertyAttribute.ReadOnly, null);
				//m.set_property(c, new JSCore.String.with_utf8_c_string("binder"), gval2jval(c,v), JSCore.PropertyAttribute.ReadOnly, null);
			    				
				o.set_property(c, new JSCore.String.with_utf8_c_string(this.definition.className), m, JSCore.PropertyAttribute.ReadOnly, null);
			    return m;
			}
			
			public void set_as_prototype(JSCore.Context c, JSCore.Object obj) {
					var p = new JSCore.Object(c, this.js_class, null);
					var pt_type_name = Type.from_instance(this).name();

					p.set_property(c, new JSCore.String.with_utf8_c_string("binder"), string_value(c, pt_type_name), JSCore.PropertyAttribute.ReadOnly, null);	
					obj.set_property(c, new JSCore.String.with_utf8_c_string("static_binder"), string_value(c, pt_type_name), JSCore.PropertyAttribute.ReadOnly, null);	
					
					obj.set_prototype(c, p);				
			} 
			
			public void init_global(JSCore.Context c, Binder? static_binder = null) {
				VRbJS.debug("INIT_GLOBAL: 001");
				var val = string_value(c, Type.from_instance(this).name());
				VRbJS.debug("INIT_GLOBAL: 002");
				c.get_global_object().set_property(c, new JSCore.String.with_utf8_c_string("binder"), val, JSCore.PropertyAttribute.ReadOnly, null);
				VRbJS.debug("INIT_GLOBAL: 003");
				set_constructor_on(c, null, static_binder);
			}
			
			// BEGIN argument utils
			public static unowned JSCore.Object? get_cb(JSCore.Context c, GLib.Value?[] args) {
				if (args.length == 0) {
					return null;
				}
				
				if (value_type(args[args.length-1]) == ValueType.OBJECT) {
					unowned JSCore.Object? o = (JSCore.Object?)args[args.length-1];
					
					if (ObjectType.from_object(c, o) == ObjectType.FUNCTION) {
						return o;
					}
				}
				
				return null;
			}
			
			public static int? check_args(GLib.Value?[] args, ValueType?[] types) {
				VRbJS.debug("CA 000");
				int i = 0;
				
				foreach(var a in args) {
					VRbJS.debug("CA 001 %d".printf(i));
					if (value_type(a) != types[i]) {
						return i;
					}
					
					i++;
				}
				
				return null;
			}
			// END argument utils
			
			
			//			
			private Binder? klass;
			public void create_bridge(owned Binder w, owned string prefix = "") {
				klass = w;
				
				
				bind("bridge", (self, args, c, out e) => {					
					string js   = compile_bridge_code(c, target, out e); 
					
					((JSUtils.Context)c).exec("""eval("%s");""".printf(js.escape(null)));
					
					return null;
				});
			}		
			
			public string compile_bridge_code(JSCore.Context c, Binder? klass = null, out JSCore.Value e) {
				string code = generate_bridge_code(c, klass, out e);
				VRbJS.debug("compile_bride_code: 001");
				return (string)jval2gval(c, ((JSUtils.Context)c).exec("""Opal.compile("%s");""".printf(code.escape(null))).native, out e);
			}	
			
			public enum BinderType {
				CLASS,
				MODULE;
			}
			
			public BinderType type = BinderType.CLASS;
			
			public string generate_bridge_code(JSCore.Context c, owned Binder? klass = null, out JSCore.Value e) {
				if (klass != null) {
					this.target = klass;
				}
				
				var module = false;
				
				if (type == BinderType.MODULE) {
					module = true;
				}
				
			
				unowned string n_name = module ? definition.className : this.target.definition.className;
				unowned string name = module ? (rb_name ?? n_name) : (this.target.rb_name ?? n_name);
				
				var code = @"$(module ? "module" : "class") $(name) $( module ? "" : @"< VRbJS.Interface(`$(n_name)`)")\n";
				
				if (module) {
					code += @"@native_type = `$(name)`";
				}
				
				Gee.HashMap<string, BCB>? map = ((Gee.HashMap<string, BCB>?)Type.from_instance(this).get_qdata(Quark.from_string("map")));
				
				if (map == null) {
					VRbJS.debug("NULL MAP1");
					raise(c, "NULL_MAP", out e);
					return null;
				}
				
				foreach (var val in map.entries) {
					if (val.key != "apply" && val.key != "bridge") {
						code += @"\n  def self.$(val.key) *o,&b\n    o.push(b) if b\n    $((val.key in constructors) ? "wrap " : "")`#{native_type}['$(val.key)'].apply(#{native_type}, #{o})` \n  end\n";
					}
				}						
				
				if (module) {
					code += "end\n";
					return code;
				}
				
				map = ((Gee.HashMap<string, BCB>?)Type.from_instance(this.target).get_qdata(Quark.from_string("map")));
				
				if (map == null) {
					VRbJS.debug("NULL MAP2");
					raise(c, "NULL_MAP", out e);
					return null;
				}
				
				foreach (var val in map.entries) {
					
					code += @"\n  def $(val.key) *o,&b\n    o.push(b) if b;\n    $((val.key in this.klass.constructors) ? "self.class.wrap " : "")`#{@_native}['$(val.key)'].apply(#{@_native}, #{o})` \n  end\n";
					
				}
				
				code += "end\n";
				//VRbJS.debug_state = true;
				VRbJS.debug("# Generated %s ruby bridge source:\n%s\n".printf(name, code));			
				
				return code;	
			}
			
		}
	}
}
