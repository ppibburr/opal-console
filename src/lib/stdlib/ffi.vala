namespace Opal {
	namespace JsFFI {
		using JSUtils;

		[CCode (cname = "dlopen")] 
		extern unowned void * dlopen (string filename, int flag);

		[CCode (cname = "dlerror")] 
		extern unowned string dlerror ();

		[CCode (cname = "dlsym")] 
		extern unowned void * dlsym (void * handle, string symbol);

		const int RTLD_LAZY = 0x00001;

		public class FFIPointerBinderKlass : Opal.JSUtils.Binder {
			public FFIPointerBinderKlass() {
				base("FFIPointerClass");
				
				bind("apply", (instance, args, c, out e) => {
					return instance;
				});		
				
				close();
			}
		}

		
		// Represents a pointer
		public class FFIPointerBinder : Opal.JSUtils.Binder {
			public FFIPointerBinder() {
				base("FFIPointer", new FFIPointerBinderKlass());
				
				
				close();
			}
		}


        // TODO: move in to own library; quite useful
        //
        // Creates a C closure 
		public class FFIClosure : GLib.Object {
			public FFI.call_interface cif;
			public FFI.type[] targs;	
			public FFI.Status? status = null;
			

				
			[CCode (has_target = false)]
			public delegate void* t_cb(void* args);

			public static void dispatch(FFI.call_interface cif, void** ret, [CCode (array_length = false)] void*[] args, FFIClosure ffic) {
				print("here %d\n", ffic.n_args);
				var argv = new void*[ffic.n_args];
				
				for (int i = 0; i < ffic.n_args; i++) {
					argv[i] = args[i];
				} 
				
				*ret = ffic.invoke(argv);
			}

			public FFI.Closure* closure {get; private set;}
			public void* bound_callback {get; private set;}
			public void* data {get; private set;}
			public int n_args {get; private set;}
			public process_delegate process {get; private set;}
			
			public delegate void* process_delegate(void*[] args, void* data);
			public void* invoke(void*[] args) {
				return process(args, data);
			}

			public FFIClosure(int n_args, void* data, process_delegate cb) {
				this.process = cb;
				this.n_args = n_args;
				this.data = data;
				
				targs = new FFI.type[3];
				targs[0] = FFI.pointer;	
				targs[1] = FFI.pointer;	
				targs[2] = FFI.pointer;			
				FFI.call_interface tcif;
				
				status = FFI.call_interface.prepare(out tcif, FFI.ABI.DEFAULT , FFI.pointer, targs);
				
				cif = tcif;		
				
				this.closure = create_closure();
			} 

			private FFI.Closure* create_closure() {
				ref();
				void* z;
				
				FFI.Closure* closure;
				closure = FFI.closure_alloc(sizeof(FFI.Closure), out z);
						
				if (closure != null) {
					if (status == FFI.Status.OK) {
					  if (FFI.prep_closure_loc(closure, ref cif, (void*)dispatch, this, z) == FFI.Status.OK) {
						  this.bound_callback = z;
						  return closure;
					  }
					}
				}
				
				this.bound_callback = null;
				
				return closure;
			}
		}
		
		// The 'data' passed to closure binding
		public class Data : GLib.Object {
			public weak JSCore.Context c; 
			public weak JSCore.Object? self; 
			public weak JSCore.Object func;
			public Data(JSCore.Context c, JSCore.Object? self, JSCore.Object func) {
				this.c = c;
				this.self = self;
				this.func = func;
			}
			
			public GLib.Value? call(void*[] args) {
				void *p = *(void**)args[0];
								
				var no = c.evaluate_script(new JSCore.String.with_utf8_c_string("new FFIPointer();"),self,null,0,null);
				GLib.Value? v = (int)p;
				((JSUtils.Object)no).set_prop(c, "address", v);
				
				GLib.Value?[] jargs = new GLib.Value?[1];
				jargs[0] = jval2gval(c, no, null);				
				
				JSUtils.call(c, self, func, jargs);			

				
				return null;
			}
		}
		
		
		public class FFIFuncBinderKlass : Opal.JSUtils.Binder {
			public FFIFuncBinderKlass() {
				base("FFIFuncClass");
				
				bind("apply", (instance, args, c, out e) => {

					return FFIFuncBinder.init_object(null, jsary2vary(c,(JSCore.Object)gval2jval(c,args[1])), c, out e);
					
				});		
				
				close();
			}
		}

        // FIXME: Maybe extract the ffi bits into thier own class?
        //        
        // Calls dynamic loaded c function
		public class FFIFuncBinder : Opal.JSUtils.Binder {
			public weak JSCore.Context default_context;
			
			public GLib.Value? invoke(JSCore.Context c, JSCore.Object self, string module, string symbol, string rtype, GLib.Value?[] atypes, GLib.Value?[] args, out JSCore.Value e) {
				FFI.call_interface cif;
				void* func;
				
		
				
				var handle = dlopen(module, RTLD_LAZY);
				
				if (handle == null) {
					raise(c, "Cannot DL %s.".printf(module), out e);
					return null;
				}
				
				func = dlsym(handle, symbol);
				
				if (func == null) {
					raise(c, "Cannot find symbol %s in %s.".printf(symbol, module), out e);
				}
				
				FFI.type r;
				FFI.type[] a = new FFI.type[atypes.length];
				
				switch (rtype) {
				case "string":
				  r = FFI.pointer;
				  break;
				case "int32":
					r = FFI.sint32;
					break;	
				case "pointer":
					r = FFI.pointer;
					break;	  
				case "void":
					r = FFI.@void;
					break;
				default:
				  raise(c, "Bad Return Type: %s".printf(rtype), out e);
				  return null;	
				}
				
				for (var i = 0; i < atypes.length; i++) {
					switch ((string)atypes[i]) {
					case "string":
						a[i] = FFI.pointer;
						break;
						
					case "pointer":
						a[i] = FFI.pointer;
						break;				
					
					case "int32":
						a[i] = FFI.sint32;
						break;
					
					default:
						Opal.debug("INVOKE: 001");
						raise(c, "Bad Type for arg_types[%d].".printf(i), out e);
						return null;
					}
				}
			
				FFI.call_interface.prepare(out cif, FFI.ABI.DEFAULT, r, a);
				
				void*[] pargs = new void*[args.length];
				string?[] str_args = new string?[0];
				int?[] int_args    = new int?[0];
				void*[] ptr_args   = new void*[0];
				
				Opal.debug_state = true;
				
				for (var i=0; i < args.length; i++) {
					switch ((string)atypes[i]) {
					case "string":
						str_args += (string?)args[i];
						pargs[i] = &str_args[str_args.length-1];
						Opal.debug("INVOKE: 802");
						break;
					
					case "pointer":
					    if (value_type(args[i]) == ValueType.OBJECT && ObjectType.from_object(c, (JSCore.Object)args[i]) == ObjectType.FUNCTION) {
							/* Acts like puts with the file given at time of enclosure. */
	
			             
							Opal.debug("CLOSURE: 001");
							ptr_args += new FFIClosure(3, new Data(default_context ?? c, self, (JSCore.Object)args[i]), (args, data) => {								
								((Data)data).call(args);
								return (void*)true;
							}).closure;

							pargs[i] = &ptr_args[ptr_args.length-1];
							
							break;
						}
						
						
					
						if (args[i] == null) {
							ptr_args += ((int)0).to_pointer();
							pargs[i] = &ptr_args[ptr_args.length-1];
							Opal.debug("FUCK");
							break;
						}
					
						var ptr = ((JSUtils.Object)args[i]).get_prop(c, "address");
						if (ptr != null) {
							ptr_args += ((int)(double)ptr).to_pointer();
							pargs[i] = &ptr_args[ptr_args.length-1];
						} else {
							Opal.debug("FUCK:");
							ptr_args += ((int)0).to_pointer();
							pargs[i] = &ptr_args[ptr_args.length-1];
						}
						break;			
					
					case "int32":
						int_args += (int)(double)args[i];
						pargs[i] = (void*)int_args[int_args.length-1];
						break;
					
					 default:
					   raise(c, "Bad type for parameter at args_types[%d]".printf(i), out e);
					   return null;
					}	
				}		
				
				GLib.Value? result;
				call_cif(cif, func, rtype, pargs, out result);
				Opal.debug("INVOKE: 999");
				return result;
			}
			
			public void call_cif(FFI.call_interface cif, void* func, string rtype, owned void*[] args, out GLib.Value? v) {	
				
				switch (rtype) {
				case "string":
					string o;
					Opal.debug("CALL: 001");
					cif.call<string*>(func, out o, args);
					Opal.debug("CALL: 002");

					
					v = (string)o;
					return;
					
				case "pointer":
					void* o;
					Opal.debug("CALL: 001");
					cif.call<void*>(func, out o, args);
					Opal.debug("CALL: 002");
					
					v = (int)o;

					
					return;			
					
				case "int32":
					int i = 44;
					Opal.debug("CALL: 003");
					cif.call<int>(func, out i, args);
					Opal.debug("CALL: 004 - %d".printf(i));

					
					v = i;
					return;	
					
				case "void":
					void* o = null;
					Opal.debug("CALL: 005");
					cif.call<void*>(func, out o, args);
					Opal.debug("CALL: 006");

					
					v = null;
					return;				
						
				default:
					return;
				} 
			}
			
			public Binder? pointer_binder;	
			public FFIFuncBinder() {
				base("FFIFunc", new FFIFuncBinderKlass());
				
				pointer_binder = new FFIPointerBinder();
				
				bind("invoke", (self, args, c, out e) => {
					Opal.debug("FUNC_INVOKE: 001");
					
					unowned Opal.JSUtils.Object ins = (Opal.JSUtils.Object)self;
					
					string module = (string)ins.get_prop(c, "module");
					string symbol = (string)ins.get_prop(c, "symbol");
					string rtype  = (string)ins.get_prop(c, "return_type");
					
					Opal.debug("FUNC_INVOKE: 002");
					
					GLib.Value?[] atypes = jsary2vary(c, (JSCore.Object)ins.get_prop(c, "args_types"));
					
					Opal.debug("FUNC_INVOKE: 003");
					
					GLib.Value? result = invoke(c, self, module, symbol, rtype, atypes, args, out e); 
					
					Opal.debug("FUNC_INVOKE: 999");
					
					if (rtype == "pointer") {
						var obj = new JSUtils.Object((JSUtils.Context)c, pointer_binder.js_class);
						obj.set_prop(c, "address", result);
						
						result = obj;
					}
					
					return result;
				});
				
				close();
				
				constructor((instance, args, c, out e)=>{
					init_object(instance, args, c, out e);	
				});
			}
			
			public static weak JSCore.Object? init_object(JSCore.Object? iobj, GLib.Value?[] args, JSCore.Context c, out JSCore.Value e) {
				Opal.debug("FUNC: 001");
			
				weak JSCore.Object? instance;		
					
				if (iobj == null) {
					var u  = new JSCore.Object(c, (JSCore.Class?)typeof(FFIFuncBinder).get_qdata(Quark.from_string("jsclass")), null);
					instance = u;
					GLib.Value v = typeof(FFIFuncBinder).name();
					((JSUtils.Object)instance).set_prop(c, "binder", v);
							
				} else {
					instance = iobj;
				}
					
				unowned JSUtils.Object obj = (Opal.JSUtils.Object)instance;
				
				ValueType?[] types = {ValueType.STRING, ValueType.STRING, ValueType.STRING, ValueType.OBJECT};
				
				var idx = check_args(args, types);
				
				Opal.debug("FC 001");
				
				if (idx != null) {
					raise(c, "Expected %s for parameter %d (have %s (%s))".printf(types[(int)idx].to_string(), idx, value_type(args[(int)idx]).to_string(), object_to_string(c,(JSCore.Object)args[(int)idx])), out e);
					return null;
				}
				
				if (ObjectType.from_object(c, (JSCore.Object)args[3]) != ObjectType.ARRAY) {
					raise(c, "Expected Array for parameter 4", out e);
					return null;
				}
				
				Opal.debug("FC 002");
				
				
				var atypes = jsary2vary(c, (JSCore.Object)args[3]);
				types = new ValueType?[atypes.length];
				
				Opal.debug("FC 003");
				
				for (var i = 0; i < atypes.length; i++) {
					Opal.debug("FC 000 %d".printf(i));
					types[i] = ValueType.STRING;
					Opal.debug("FC 000 A %d".printf(i));
				}
				
				idx = check_args(atypes, types);
				
				Opal.debug("FC 004");
				
				if (idx != null) {
					raise(c, "Bad Type value in arg_types[%d]".printf(idx), out e);
					return null;
				}
				
				obj.set_prop(c, "module",      args[0]);
				obj.set_prop(c, "symbol",      args[1]);
				obj.set_prop(c, "return_type", args[2]);
				obj.set_prop(c, "args_types",  args[3]);


				Opal.debug("FUNC: 999");
				
				return instance;		
			}
			
			public static int? check_args(GLib.Value?[] args, ValueType?[] types) {
				Opal.debug("CA 000");
				int i = 0;
				print("%d\n",args.length);
				foreach(var a in args) {
					Opal.debug("CA 001 %d".printf(i));
					if (value_type(a) != types[i]) {
						return i;
					}
					
					i++;
				}
				
				return null;
			}
		}
	}
}
