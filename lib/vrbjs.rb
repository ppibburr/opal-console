
module VRbJS

  class << self; def native_type; `VRbJS`; end; end

  def self.require *o, &b; o.push(b) if b; `#{native_type}['require'].apply(#{native_type}, #{o})`; end

end
