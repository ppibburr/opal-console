namespace Spawn {
    using VRbJS;
    using JSUtils;
    
    
    public class SpawnBinder : Binder {
        public SpawnBinder() {
            base("Spawn"); 
            type = BinderType.MODULE;
            
            bind("system", (self, args, c, out e)=>{
                GLib.Value? v;
                
                bool has_options  = false;
                bool has_env      = false;
                bool has_cmd_arg0 = false;
                
                var env = Environ.get();
                     
                var options = new Gee.HashMap<string, GLib.Value?>();     
                                
                if (args.length > 1 && value_type(args[args.length-1]) == ValueType.OBJECT) {
                    // has options
                      has_options = true;
                    
                      string[] keys;
                      GLib.Value?[] values;
                      
                      var map = hash2map(c, (JSCore.Object)args[args.length-1], out keys, out values);
                      
                      if (!map) {
                          raise(c, "Invalid Options object: must be Hash", out e);
                          return null;
                      } 
                      
                      int i = 0;
                      foreach (var k in keys) {
                          options[k] = values[i];
                          
                          i++;
                      }                   
                }
                
                if (args.length > 1 && value_type(args[0]) == ValueType.OBJECT) {
                    if (ObjectType.from_object(c, (JSCore.Object)args[0]) != ObjectType.ARRAY) {
                      // has environment
                      
                      has_env = true;
                      
                      string[] keys;
                      GLib.Value?[] values;
                      
                      var map = hash2map(c, (JSCore.Object)args[0], out keys, out values);
                      
                      if (!map) {
                          raise(c, "Invalid ENV object: must be Hash", out e);
                          return null;
                      }
                      
                      env = new string[0];
                      
                      int i = 0;
                      foreach (var k in keys) {
                          if (value_type(values[i]) != ValueType.STRING) {
                              raise(c, "ENV Values must be String", out e);
                              return null;
                          }
                          
                          env += "%s=%s".printf((string)k,(string)values[i]);
                          
                          i++;
                      }
                      
                    } else {
                      // has [command, arg[0]]
                      has_cmd_arg0 = true;
                    }
                } 
                
                if (!has_env && !has_cmd_arg0 && value_type(args[0]) != ValueType.STRING) {
                    raise(c, "system: invalid parameter 1", out e);
                    return null;
                }               
                
                int status = 0;
                
                var start = has_env ? 1 : 0;
                var end   = has_options ? args.length - 2 : args.length-1;
                VRbJS.debug("system: s %d, e %d, %d%d%d".printf(start, end, (int)has_cmd_arg0, (int)has_env, (int)has_options));
                if (!has_cmd_arg0) {
                    if (end - start == 0) {
                        v = system_shell((string)args[start], out status, options, env);
                    } else {
                        string[] argv = new string[0];
                        
                        for (int i=start; i<=end; i++) {
                            argv += (string)args[i];
                        }
                        
                        v = system_cmd(argv, out status, false, options, env);
                    }
                } else {
                    string[] argv = new string[0];
                    
                    var cmd_argv0 = jsary2vary(c, (JSCore.Object)args[start]);
                    
                    argv += (string)cmd_argv0[0];
                    argv += (string)cmd_argv0[1];
                    
                    for (int i=start+1; i<=end; i++) {
                        argv += (string)args[i];
                    }
                    
                    v = system_cmd(argv, out status, true, options, env);
                }
                
	              return v;
            });
            
            close();
        }
    }
    
    public static SpawnFlags get_spawn_flags(Gee.HashMap<string, GLib.Value?> options, out string? spawn_arg) {
        SpawnFlags flags = SpawnFlags.SEARCH_PATH | SpawnFlags.CHILD_INHERITS_STDIN | SpawnFlags.SEARCH_PATH_FROM_ENVP;
        
        string? a = null;
        
        if ("stderr" in options.keys) {
            if (options["stderr"] == null || value_type(options["stderr"]) == ValueType.NULL) {
                flags = flags | SpawnFlags.STDERR_TO_DEV_NULL;
            
            } else if (value_type(options["stderr"]) == ValueType.DOUBLE) {
                if ((int)(double)options["stderr"] == 0) {
                    flags = flags | SpawnFlags.STDERR_TO_DEV_NULL;
                } else {
                    sa = "2>&%d".printf((int)(double)options["stderr"]);
                }
                
            // `nil` appears as object...
            } else if (value_type(options["stderr"]) == ValueType.OBJECT) {
                    flags = flags | SpawnFlags.STDERR_TO_DEV_NULL;
            }
        }
        
        if ("stdout" in options.keys) {
            if (options["stdout"] == null || value_type(options["stdout"]) == ValueType.NULL) {
                flags = flags | SpawnFlags.STDOUT_TO_DEV_NULL;
            
            } else if (value_type(options["stdout"]) == ValueType.DOUBLE) {
                if ((int)(double)options["stdout"] == 0) {
                    flags = flags | SpawnFlags.STDOUT_TO_DEV_NULL;
                } else {
                    sa = (sa ?? "") + "1>&%d".printf((int)(double)options["stdout"]);
                }
                
            // `nil` appears as object...
            } else if (value_type(options["stdout"]) == ValueType.OBJECT) {
                    flags = flags | SpawnFlags.STDOUT_TO_DEV_NULL;
            }
        }      
        
        spawn_args = sa;
        
        return flags;
    }
    
    
    public static bool system_shell(string cmd_line, out int status, Gee.HashMap<string, GLib.Value?> options, string[] spawn_env = Environ.get ()) {
	    try {
		    string? shell = Environment.get_variable("SHELL") ?? "/bin/sh";
		    string[] spawn_args = {shell, "-c", cmd_line};

        SpawnFlags flags  = get_spawn_flags(options, out spawn_args);      

		    Process.spawn_sync (Environment.get_variable("PWD") ?? "./",
							    spawn_args,
							    spawn_env,
							    flags,
							    null,
							    null,
							    null,
							    out status);

	    } catch (SpawnError e) {
		    return false;
	    }

	    return true;
    }

    public static bool system_cmd(string[] argv, out int status, bool file_argv0, Gee.HashMap<string, GLib.Value?> options, string[] spawn_env = Environ.get ()) {
	    try {
		    string[] spawn_args = argv;

        SpawnFlags flags = SpawnFlags.SEARCH_PATH | SpawnFlags.CHILD_INHERITS_STDIN | SpawnFlags.SEARCH_PATH_FROM_ENVP;

        if (file_argv0) {
            flags = SpawnFlags.SEARCH_PATH | SpawnFlags.CHILD_INHERITS_STDIN | SpawnFlags.SEARCH_PATH_FROM_ENVP | SpawnFlags.FILE_AND_ARGV_ZERO;
        }

		    Process.spawn_sync (Environment.get_variable("PWD") ?? "./",
							    spawn_args,
							    spawn_env,
							    flags,
							    null,
							    null,
							    null,
							    out status);

	    } catch (SpawnError e) {
		    return false;
	    }

	    return true;
    }    
    
    public static bool hash2map(JSCore.Context c, JSCore.Object hash, out string[] keys, out GLib.Value?[] values) {
        var map = ((JSUtils.Object)hash).get_prop(c, "smap");
        
        if (map == null) {
            return false;
        }
        
        var a   = c.evaluate_script(new JSCore.String.with_utf8_c_string("Object.keys(this);"), (JSCore.Object)map, null, 0, null);
        var g   = jsary2vary(c,(JSCore.Object)a);
        
        keys   = new string[g.length];
        values = new GLib.Value?[g.length];
        
        int i = 0;
        foreach (var k in g) {
            keys[i]   = (string)k;
            values[i] = ((JSUtils.Object)map).get_prop(c, (string)k);
            i++;
        }
        
        return true;
    }

    public static Runtime.LibInfo? init(Runtime r) {
        var info = new Runtime.LibInfo();
        info.interfaces = {new SpawnBinder()};
        info.interfaces[0].create_toplevel_module(r.context);
        return info;
    }
}
