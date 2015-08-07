module VRbJS
  def self.Interface(n)
    klass = Class.new(VRbJS::Object)
    klass.set_native_type n
    return klass
  end
  
  class Object
    def self.inherited q
      q.set_native_type native_type
    end 
  
    def self.set_native_type t
      @native_type = t
    end
    
    def self.native_type
      @native_type
    end
    
    def self.new(*args)
      ins = allocate()
      ins.send :initialize
      ins._native = `#{self.native_type}.apply(null, #{args})`
      return ins
    end
    
    def self.wrap(n,*o,&b)
      ins=allocate()
      ins.send(:initialize)
      ins._native = n
      return ins
    end
    
    attr_accessor :_native
  end
end

