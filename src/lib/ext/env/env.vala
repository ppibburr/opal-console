namespace Env {
  using VRbJS;
  using JSUtils;
  
  public class EnvBinderKlass : Binder {
    public EnvBinderKlass() {
      base("EnvKlass");
      close();
    }
  }  
  
  public class EnvBinder : Binder {
    public EnvBinder() {
      base("Env", new EnvBinderKlass());
      
      bind("get", (self, args)=>{
          GLib.Value? v = Environment.get_variable((string)args[0]);
          
          return v;
      }, false, 1);
      
      bind("set", (self, args)=>{
          Environment.set_variable((string)args[0], (string)args[1], true);
          
          return args[1];
      }, false, 2);      
      
      bind("unset", (self, args)=>{
          GLib.Value? v = Environment.get_variable((string)args[0]);
          Environment.unset_variable((string)args[0]);
          
          return v;
      }, false, 1);    
      
      bind("list", (self, args, c, out e)=>{
          string[] l = Environment.list_variables();
          
          GLib.Value?[] vary = new GLib.Value?[0];
          
          foreach (var v in l) {
              GLib.Value? gv = v;
              vary += gv;
          }

          vary+=null;
  
          void*[] a = vary2jary(c, vary);

          var o = new JSCore.Object.array(c, l.length, a, out e);
          VRbJS.debug("ASSHOLE!");          
          return jval2gval(c, o, out e);
      });        
      
      close();
    }
  }

  public static Runtime.LibInfo? init(Runtime r) {
    Runtime.LibInfo? info   = new Runtime.LibInfo();
    info.interfaces = {new EnvBinder().prototype};
  
    r.add_toplevel_class(info.interfaces[0].target);
    
    return info;
  }
}
