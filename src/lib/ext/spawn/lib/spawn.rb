
module Spawn 
  @native_type = `Spawn`
  def self.system *o,&b
    o.push(b) if b
    `#{@native_type}['system'].apply(#{@native_type}, #{o})` 
  end
end


VRbJS.require "spawn/spawn"
