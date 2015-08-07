module VRbJS 
  @native_type = `VRbJS`
  def self.main_quit *o,&b
    o.push(b) if b
    `#{@native_type}['main_quit'].apply(#{@native_type}, #{o})` 
  end

  def self.require *o,&b
    o.push(b) if b
    `#{@native_type}['require'].apply(#{@native_type}, #{o})` 
  end

  def self.exit *o,&b
    o.push(b) if b
    `#{@native_type}['exit'].apply(#{@native_type}, #{o})` 
  end

  def self.on_ready *o,&b
    o.push(b) if b
    `#{@native_type}['on_ready'].apply(#{@native_type}, #{o})` 
  end

  def self.set_debug *o,&b
    o.push(b) if b
    `#{@native_type}['set_debug'].apply(#{@native_type}, #{o})` 
  end
end
