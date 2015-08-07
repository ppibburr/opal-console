VRbJS.require 'ffi'
module GObject
  DL_LIB = "libgobject-2.0.so"
    
  FFI::Func.register_callback(:GtkWidgetDeleteEventCallback, :bool, [:pointer, :pointer, :pointer])
  
  def self.signal_connect_data(o, n, &b)
    FFI::Func.new(DL_LIB, :g_signal_connect_data, :void, [:pointer, :string, :GtkWidgetDeleteEventCallback, :pointer, :pointer, :int32]).invoke(o.to_ptr, n, b, nil, nil, 0.0)
  end
  
  def self.type_from_name name
    FFI::Func.new(DL_LIB, :g_type_from_name, :pointer, [:string]).invoke(name)
  end
  
  def self.type_name type
    FFI::Func.new(DL_LIB, :g_type_name, :string, [:pointer]).invoke(type)
  end
  
  class self::Object
    def signal_connect(name, &b)
      GObject.signal_connect_data(self, name, &b)
    end
  end
  
  class MainLoop
    def to_ptr
      @ptr
    end
    
    def initialize
      @ptr = FFI::Func.new(DL_LIB, :g_main_loop_new, :pointer, [:pointer, :pointer]).invoke(nil, nil)
    end
    
    def run
      FFI::Func.new(DL_LIB, :g_main_loop_run, :void, [:pointer]).invoke(to_ptr)
    end
  end
end
