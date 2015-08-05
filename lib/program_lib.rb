class Program < VRbJS.Interface(`Program`)

  def run *o,&b
    o.push(b) if b;
    `#{@_native}['run'].apply(#{@_native}, #{o})` 
  end

  def append_argv *o,&b
    o.push(b) if b;
    `#{@_native}['append_argv'].apply(#{@_native}, #{o})` 
  end

  def write *o,&b
    o.push(b) if b;
    `#{@_native}['write'].apply(#{@_native}, #{o})` 
  end

  def read *o,&b
    o.push(b) if b;
    `#{@_native}['read'].apply(#{@_native}, #{o})` 
  end

  def dump *o,&b
    o.push(b) if b;
    `#{@_native}['dump'].apply(#{@_native}, #{o})` 
  end
end
