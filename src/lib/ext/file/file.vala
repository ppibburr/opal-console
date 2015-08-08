using VRbJS;
namespace File {
	using JSUtils;
	public class JFile : JSUtils.Binder {
	  public JFile () {
		base("File", new JFileKlass());

		bind("each", (self, a,c,out e)=>{
			unowned JSCore.Object? cb = get_cb(c,a);
			
			if (cb == null) {
				raise(c, "No Block Given.", out e);
				return null;
			}
			
			GLib.File file = self.get_private<GLib.File>();
			try {
				var d_is = new DataInputStream (file.read ());
				string line;

				while ((line = d_is.read_line (null)) != null) {
					GLib.Value v = line;
					GLib.Value?[] args = new GLib.Value?[1];
					
					args[0] = v;
					
					call(c, self, cb, args);
				}
				
				//
			} catch (Error err) {
				raise(c, "%s".printf(err.message), out e);
			}
			return null;
		});
		
		constructor((instance, args, c, out e)=> {
			init_object(instance, args, c, out e);
		});
		
		close();
	  }
	  
	  public static JSCore.Object? init_object(JSCore.Object? instance, GLib.Value?[] args, JSCore.Context c, out JSCore.Value e) {
			var file = _add((string)args[0]);
			//_add(file);
			if (!file.query_exists ()) {
				raise(c, "File '%s' doesn't exist.\n".printf(file.get_path ()), out e);
				return null;
			}
			
			if (instance != null) {
				instance.set_private<GLib.File>(file);	
			} else {
				var i = new JSCore.Object(c, (JSCore.Class?)typeof(JFile).get_qdata(Quark.from_string("jsclass")), file);
				GLib.Value v = typeof(JFile).name();
				i.set_property(c, new JSCore.String.with_utf8_c_string("binder"), gval2jval(c, v), JSCore.PropertyAttribute.ReadOnly, null);
				return i;
			}
			
			return null;	  
	  }
	  
	  private static GLib.File[] _files;
	  static construct {
		  _files = new GLib.File[0];
	  }
	  
	  private static GLib.File _add(string path) {
		  _files += GLib.File.new_for_path (path);
		 
		  return _files[_files.length-1];
	  }
	}


	public class JFileKlass : VRbJS.JSUtils.Binder {
		public JFileKlass() {
			base("FileClass");
			bind("read", (self, args, c, out e) => {
				if (args.length < 1 || value_type(args[0]) != ValueType.STRING) {
					raise(c, "Path argument must be string", out e);
					return null;
				}
				
				var path = (string)args[0];
				
				string contents;
				
				FileUtils.get_contents(path, out contents, null);
				
				GLib.Value? v = contents;
				
				return v;
			});
			
			ValueType?[] e_types = {ValueType.STRING};
			bind("exist",(self, args, c, out e)=>{
			  var path = (string)args[0];
			  GLib.Value? v = FileUtils.test(path, FileTest.EXISTS);
			  return v;
			}, false, 1, e_types);
			
			ValueType?[] id_types = {ValueType.STRING};
			bind("is_directory",(self, args, c, out e)=>{
			  var path = (string)args[0];
			  GLib.Value? v = FileUtils.test(path, FileTest.IS_DIR);
			  return v;
			}, false, 1, id_types);			
			
			ValueType?[] if_types = {ValueType.STRING};
			bind("is_file",(self, args, c, out e)=>{
			  var path = (string)args[0];
			  GLib.Value? v = !FileUtils.test(path, FileTest.IS_DIR);
			  return v;
			}, false, 1, if_types);				
			
			bind("apply", (instance, args, c, out e) => {
				GLib.Value?[] a = jsary2vary(c, (JSCore.Object)args[1]); 
				return JFile.init_object(null, a, c, out e);
			});				
			
			close();
		}
	}
	
	public static VRbJS.Runtime.LibInfo? init(Runtime r) {
		var file = new JFile();
		
		r.add_toplevel_class(file);

		Runtime.LibInfo? info = new Runtime.LibInfo();
		
		info.iface_name = "VRbJS";
		info.interfaces = {file.prototype};
		
		return info;
	}		
}

