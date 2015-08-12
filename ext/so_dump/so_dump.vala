namespace SoDump {
	using JSUtils;
	
	public class Dumper : Binder {
		public weak Context context;
		
		public Dumper(Context c) {
			base("SoDump");
			this.context = c;
			this.refer = "VRbJS.SoDump";
			this.iface_type = BinderType.MODULE;
			
			bind("dump", (self, args, c, out e) => {
				string? path = search_file(context.get_environment().search_paths, (string)args[0], "so");
				
				if (path != null) {
					if (path in context.get_environment().required) {
					} else {
						context.load_so(path);
					}
					
					var info = context.libinfo_by_name(path);
					
					return dump_so(info);
				}
				
				return null;
			},1);
			
			close();
		}
	}
	
	public static string dump_so(LibInfo info) {
		var ident = 0;
		string code = "";
		if (info.iface != null) {
			code += @"module $(info.iface)";
			code += "\n";
			ident = 2;
		}
					
		foreach (var i in info.interfaces) {
			code += "\n"+(string.nfill(ident, ' ')) + (i.iface_type == BinderType.MODULE ? "module" : "class") + @" $(i.definition.className)\n";
			
		    ident += 2;
			
			if (i.iface_type != BinderType.MODULE) {
				code += string.nfill(ident, ' ') + @"def self.new *o, &b; o.push(b) if b; ins = allocate; ins.instance_variable_set(\"@native\", `new $(i.refer)(#{o})`); return ins; end\n";
				code += string.nfill(ident, ' ') + "def self.wrap n; ins = allocate; ins.instance_variable_set(\"@native\", n); return ins ; end\n";								
			}
			
			code += "\n" + string.nfill(ident, ' ') + @"class << self; def native_type; `$(i.refer)`; end; end\n\n";
			
			if (i.prototype != null) {
				var map = (Gee.HashMap<string, BoundFunction>?)Type.from_instance(i.prototype).get_qdata(Quark.from_string("map"));
				
				if (map != null) {
					foreach (var fun in map.keys) {
						bool constructor = map[fun].is_constructor;
						
						code += string.nfill(ident, ' ') + @"def self.$fun *o, &b; o.push(b) if b; $(constructor ? "wrap " : "")`#{native_type}['$fun'].apply(#{native_type}, #{o})`; end\n";
					}
				}
			}
			
			var map = (Gee.HashMap<string, BoundFunction>?)Type.from_instance(i).get_qdata(Quark.from_string("map"));
			
			if (map != null) {
				foreach (var fun in map.keys) {
					bool constructor = map[fun].is_constructor;
					if (i.iface_type != BinderType.MODULE) {
						code += string.nfill(ident, ' ') + @"def $fun *o, &b; o.push(b) if b; `#{@native}['$fun'].apply(#{@native}, #{o})`; end\n";
					} else {
						code += string.nfill(ident, ' ') + @"def self.$fun *o, &b; o.push(b) if b; $(constructor ? "wrap " : "")`#{native_type}['$fun'].apply(#{native_type}, #{o})`; end\n";
					}
				}
			}			
			
			ident -= 2;
			
			code += "\n" + string.nfill(ident, ' ') + "end\n";
		}
		
		if (info.iface != null) {
			code += "\nend\n\n";
		}
		
		return code;
	}
	
	public static LibInfo?  init(Context c) {
		var dumper = new Dumper(c);

		var vrbjs = (JSUtils.Object)((JSUtils.Object)c.get_global_object()).get_prop(c, "VRbJS");
		
		dumper.create_module(c, vrbjs);
		
		var info = new LibInfo();
		info.iface = "VRbJS";
		info.interfaces = {dumper};
		return info;
	}
}
