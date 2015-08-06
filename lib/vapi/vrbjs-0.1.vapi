/* vrbjs-0.1.vapi generated by valac 0.28.0, do not modify. */

namespace VRbJS {
	namespace JSUtils {
		[CCode (cheader_filename = "vrbjs.h")]
		public class Binder {
			public class BCB {
				public string[]? anames;
				public VRbJS.JSUtils.ValueType?[] atypes;
				public VRbJS.JSUtils.Binder.b_cb func;
				public int n_args;
				public string name;
				public BCB (string n, int n_args, VRbJS.JSUtils.ValueType?[] atypes = null, string[]? anames = null, VRbJS.JSUtils.Binder.b_cb func);
			}
			public enum BinderType {
				CLASS,
				MODULE
			}
			public delegate GLib.Value? b_cb (JSCore.Object self, GLib.Value?[] args, JSCore.Context c, out JSCore.Value e);
			public delegate void c_cb (JSCore.Object instance, GLib.Value?[] args, JSCore.Context c, out JSCore.Value err);
			public delegate void f_cb (JSCore.Object o);
			public delegate void i_cb (JSCore.Context c, JSCore.Object o);
			public JSCore.ClassDefinition definition;
			public JSCore.Class js_class;
			public VRbJS.JSUtils.Binder? prototype;
			public string? rb_name;
			public VRbJS.JSUtils.Binder? target;
			public VRbJS.JSUtils.Binder.BinderType type;
			public Binder (string class_name, VRbJS.JSUtils.Binder? prototype = null);
			public static void add_constructor (string name);
			public virtual void bind (string name, VRbJS.JSUtils.Binder.b_cb cb, bool constructor = false, int n_args = -1, VRbJS.JSUtils.ValueType?[] atypes = null, string[]? anames = null);
			public static int? check_args (GLib.Value?[] args, VRbJS.JSUtils.ValueType?[] types);
			public void close ();
			public string compile_bridge_code (JSCore.Context c, VRbJS.JSUtils.Binder? klass = null, out JSCore.Value e);
			public void constructor (VRbJS.JSUtils.Binder.c_cb cb);
			public void create_bridge (owned VRbJS.JSUtils.Binder w, owned string prefix = "");
			public JSCore.Object create_toplevel_module (JSCore.Context c);
			public static void ensure_init (VRbJS.JSUtils.Binder target);
			public void finalizer (VRbJS.JSUtils.Binder.f_cb cb);
			public string generate_bridge_code (JSCore.Context c, owned VRbJS.JSUtils.Binder? klass = null, out JSCore.Value e);
			public static VRbJS.JSUtils.Binder.BCB get_binding (string binder, string name);
			public static unowned JSCore.Object? get_cb (JSCore.Context c, GLib.Value?[] args);
			public void init_global (JSCore.Context c, VRbJS.JSUtils.Binder? static_binder = null);
			public void initializer (VRbJS.JSUtils.Binder.i_cb cb);
			public static void raise (JSCore.Context ctx, string msg, out JSCore.Value err);
			public void set_as_prototype (JSCore.Context c, JSCore.Object obj);
			public void set_binding (string n, int n_args = -1, VRbJS.JSUtils.ValueType?[] atypes = null, string[]? anames = null, VRbJS.JSUtils.Binder.b_cb cb);
			public JSCore.Object set_constructor_on (JSCore.Context c, owned JSCore.Object? t = null, owned VRbJS.JSUtils.Binder? prototype_class = null);
			public static string[] constructors { get; private set; }
			public JSCore.StaticFunction[] static_functions { get; private set; }
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public class Context : JSCore.GlobalContext {
			public Context (JSCore.Class? kls = null);
			public static string _read_string (JSCore.Context ctx, JSCore.Value val);
			public VRbJS.JSUtils.Value exec (string code);
			public JSCore.Object global_object ();
			public string read_string (JSCore.Value val);
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public class Object : JSCore.Object {
			public Object (VRbJS.JSUtils.Context c, JSCore.Class? klass = null, void* data = null);
			public GLib.Value? get_prop (JSCore.Context c, string name);
			public void set_prop (JSCore.Context c, string name, GLib.Value? v);
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public class Value {
			public Value (JSCore.Context ctx, JSCore.Value? native);
			public static void string (JSCore.Context ctx, global::string str, out JSCore.Value val);
			public JSCore.Object to_object ();
			public global::string to_string ();
			public JSCore.Context context { get; private set; }
			public JSCore.Value? native { get; private set; }
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public enum ObjectType {
			OBJECT,
			FUNCTION,
			CONSTRUCTOR,
			ARRAY;
			public static VRbJS.JSUtils.ObjectType from_object (JSCore.Context c, JSCore.Object obj);
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public enum ValueType {
			NULL,
			OBJECT,
			STRING,
			DOUBLE,
			FLOAT,
			INT,
			BOOLEAN
		}
		[CCode (cheader_filename = "vrbjs.h")]
		public static GLib.Value? call (JSCore.Context c, JSCore.Object self, JSCore.Object fun, GLib.Value?[] args);
		[CCode (cheader_filename = "vrbjs.h")]
		public static JSCore.Value gval2jval (JSCore.Context c, GLib.Value? val);
		[CCode (cheader_filename = "vrbjs.h")]
		public static GLib.Value?[] jsary2vary (JSCore.Context c, JSCore.Object obj);
		[CCode (cheader_filename = "vrbjs.h")]
		public static GLib.Value? jval2gval (JSCore.Context c, JSCore.Value arg, out JSCore.Value e);
		[CCode (cheader_filename = "vrbjs.h")]
		public static string object_to_string (JSCore.Context c, JSCore.Object obj);
		[CCode (cheader_filename = "vrbjs.h")]
		public static JSCore.Value string_value (JSCore.Context c, string val);
		[CCode (cheader_filename = "vrbjs.h")]
		public static string v2str (GLib.Value? val);
		[CCode (cheader_filename = "vrbjs.h")]
		public static VRbJS.JSUtils.ValueType value_type (GLib.Value? val);
	}
	[CCode (cheader_filename = "vrbjs.h")]
	public class Runtime {
		public class Console : VRbJS.JSUtils.Binder {
			public Console ();
		}
		public class LibInfo {
			public string? iface_name;
			public VRbJS.JSUtils.Binder?[] interfaces;
			public string? parent_iface;
			public LibInfo ();
		}
		[CCode (has_target = false)]
		public delegate VRbJS.Runtime.LibInfo? init_lib (VRbJS.Runtime self);
		public static string? lib_dir;
		public Runtime (bool? parser = null, string[]? argv = null, VRbJS.JSUtils.Context? context = null);
		public VRbJS.JSUtils.Binder add_toplevel_class (VRbJS.JSUtils.Binder klass);
		public VRbJS.JSUtils.Value exec (string code);
		public bool f_exist (string path);
		protected void init_console (owned VRbJS.JSUtils.Binder? console_class = null);
		public void init_opal (bool parser = false, string[] argv = new string[0]);
		public VRbJS.JSUtils.Value load (string path);
		public void load_parser ();
		public VRbJS.Runtime.LibInfo? load_so (owned string name);
		public bool require (string name, bool no_so = false);
		public string[] argv { get; set; }
		public VRbJS.JSUtils.Context context { get; }
		public VRbJS.JSUtils.Binder? global_class { get; private set; }
	}
	[CCode (cheader_filename = "vrbjs.h")]
	public static bool debug_state;
	[CCode (cheader_filename = "vrbjs.h")]
	public const string OPAL;
	[CCode (cheader_filename = "vrbjs.h")]
	public const string OPAL_PARSER;
	[CCode (cheader_filename = "vrbjs.h")]
	public const string VERSION;
	[CCode (cheader_filename = "vrbjs.h")]
	public static void debug (string msg);
}
