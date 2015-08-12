module VRbJS

  module SoDump

    class << self; def native_type; `VRbJS.SoDump`; end; end

    def self.dump *o, &b; o.push(b) if b; `#{native_type}['dump'].apply(#{native_type}, #{o})`; end

  end

end

