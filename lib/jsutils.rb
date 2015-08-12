
module JSUtils

  class << self; def native_type; `JSUtils`; end; end

  def self.init_seed *o, &b; o.push(b) if b; `#{native_type}['init_seed'].apply(#{native_type}, #{o})`; end
  def self.require *o, &b; o.push(b) if b; `#{native_type}['require'].apply(#{native_type}, #{o})`; end
  def self.get_env *o, &b; o.push(b) if b; `#{native_type}['get_env'].apply(#{native_type}, #{o})`; end
  def self.spawn *o, &b; o.push(b) if b; `#{native_type}['spawn'].apply(#{native_type}, #{o})`; end
  def self.exit *o, &b; o.push(b) if b; `#{native_type}['exit'].apply(#{native_type}, #{o})`; end
  def self.add_search_path *o, &b; o.push(b) if b; `#{native_type}['add_search_path'].apply(#{native_type}, #{o})`; end
  def self.set_argv *o, &b; o.push(b) if b; `#{native_type}['set_argv'].apply(#{native_type}, #{o})`; end
  def self.get_variable *o, &b; o.push(b) if b; `#{native_type}['get_variable'].apply(#{native_type}, #{o})`; end
  def self.get_file *o, &b; o.push(b) if b; `#{native_type}['get_file'].apply(#{native_type}, #{o})`; end
  def self.waitpid *o, &b; o.push(b) if b; `#{native_type}['waitpid'].apply(#{native_type}, #{o})`; end
  def self.set_file *o, &b; o.push(b) if b; `#{native_type}['set_file'].apply(#{native_type}, #{o})`; end
  def self.load_so *o, &b; o.push(b) if b; `#{native_type}['load_so'].apply(#{native_type}, #{o})`; end
  def self.get_argv *o, &b; o.push(b) if b; `#{native_type}['get_argv'].apply(#{native_type}, #{o})`; end
  def self.set_variable *o, &b; o.push(b) if b; `#{native_type}['set_variable'].apply(#{native_type}, #{o})`; end

end

class Console
  def self.new *o, &b; o.push(b) if b; ins = allocate; ins.instance_variable_set("@native", `new Console(#{o})`); return ins; end
  def self.wrap n; ins = allocate; ins.instance_variable_set("@native", n); return ins ; end

  class << self; def native_type; `Console`; end; end

  def log *o, &b; o.push(b) if b; `#{@native}['log'].apply(#{@native}, #{o})`; end
  def warn *o, &b; o.push(b) if b; `#{@native}['warn'].apply(#{@native}, #{o})`; end

end
