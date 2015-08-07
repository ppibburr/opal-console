VRbJS.require "gtk"
module VRbJS
  class App
    attr_reader :window
    def initialize(title, size = [400,400])
      w = Gtk::Window.new(0, title)

      w.add VRbJS.webview
      w.size_request = size
      
      @window = w   
    end
    
    def run
      window.show_all 
    end
    
    def exit code = 0
      VRbJS.exit(code)
    end
    
    def at_exit &b
      window.signal_connect("delete-event", &b)   
    end
  end
end
