VRbJS.require 'ffi'
VRbJS.require 'gobject'

module VRbJS
  def self.load_status
    FFI::Func.new("libwebkitgtk-3.0.so", :webkit_web_view_get_load_status, :int32, [:pointer]).invoke(@webview.to_ptr)
  end

  def self.on_load_status &b
    GObject.signal_connect_data(@webview, "notify::load-status", &b)
  end
  
  class << self; attr_reader :webview; end
  
  @webview = FFI::Pointer.new();

  `#{@webview._native}.address = _vrbjs_webview_address`  
  
  def @webview.to_ptr
    self._native
  end  
  
  on_load_status do
    if load_status == 2
      if @on_load_cb
        @on_load_cb.call()
      end
    end
    false
  end
  
  def self.on_load(&b)
    @on_load_cb = b
  end
end
