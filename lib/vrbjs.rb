module VRbJS 
  @native_type = `VRbJS`
  def self.require *o,&b
    o.push(b) if b
    `#{@native_type}['require'].apply(#{@native_type}, #{o})` 
  end

  def self.set_debug *o,&b
    o.push(b) if b
    `#{@native_type}['set_debug'].apply(#{@native_type}, #{o})` 
  end
end
