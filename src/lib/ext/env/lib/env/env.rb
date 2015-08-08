class Env
  include Enumerable
  def each &b
    list().each do |n|
      b.call(n, get(n))
    end
  end
  
  def [] k
    get(k)
  end
  
  def []= k,v
    if v == nil
      unset(k)
    end
    
    
    if !v.is_a?(String)
      raise "TypeError: cant convert #{v.class} into String"
    end
  
    set(k, v)
  end
  
  def keys
    a = []
    each do |k,v| a << k end
    a
  end
end

ENV = Env.wrap(`new Env()`);
