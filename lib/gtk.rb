module GObject
  DL_LIB = "libgobject-2.0.so"
  #`Opala.set_debug(true)`
  
  
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

module Gtk
  DL_LIB = "libgtk-3.so"

  def self.main()
    FFI::Func.new(DL_LIB, :gtk_main, :void, []).invoke()
  end

  def self.init()
    FFI::Func.new(DL_LIB, :gtk_init, :void, [:pointer, :pointer]).invoke(nil, nil)
  end  

  module Container
    def add(w)
      FFI::Func.new(DL_LIB, :gtk_container_add, :void, [:pointer, :pointer]).invoke(self.to_ptr, w.to_ptr)
    end
  end

  class Widget < GObject::Object
    def to_ptr
      @ptr
    end

    def show_all()
      FFI::Func.new(DL_LIB, :gtk_widget_show_all, :void, [:pointer]).invoke(self.to_ptr)
    end

    def size_request= sary
      FFI::Func.new(DL_LIB, :gtk_widget_set_size_request, :void, [:pointer, :int32, :int32]).invoke(self.to_ptr, sary[0], sary[1])
    end   
    
    def self.wrap(n)
      ins = allocate()
      ins.instance_variable_set("@ptr", n);
      return ins;
    end 
  end

  class Window < Widget
    include Container
    def initialize(type, title = nil)
      @ptr = FFI::Func.new(DL_LIB, :gtk_window_new, :pointer, [:int32]).invoke(type)
      
      if title
        self.title= title
      end
    end
    
    def title= str
      FFI::Func.new(DL_LIB, :gtk_window_set_title, :void, [:pointer, :string]).invoke(self.to_ptr, str)
    end
  end
  
  class Label < Widget
    def initialize str=""
      @ptr = FFI::Func.new(DL_LIB, :gtk_label_new, :pointer, [:string]).invoke(str)
    end
  end
end
